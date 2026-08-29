# main.tf

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "gitops-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  authentication_mode = "API_AND_CONFIG_MAP"
  enable_irsa         = true

  timeouts = {
    create = "60m"
    update = "60m"
    delete = "30m"
  }

  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  access_entries = {
    admin_user = {
      principal_arn = var.admin_principal_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_cluster_443 = {
      description                   = "Cluster API to node kubelets/webhooks"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelet"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_all = {
      description = "Node to node all traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      subnet_ids = module.vpc.private_subnets

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      # Note: AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, and
      # AmazonEC2ContainerRegistryReadOnly are attached by default by
      # this module version's node group submodule — no need to
      # re-attach them here.
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  depends_on = [
    module.vpc
  ]
}

# IRSA role for the EBS CSI driver addon — required for PVC/PV provisioning
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  depends_on = [
    module.eks
  ]
}

# Standalone addon resource (kept outside module.eks's addons map) so the
# addon -> IRSA role -> cluster dependency chain doesn't form a cycle back
# through module.eks's own addons input.
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn

  depends_on = [
    module.eks,
    module.ebs_csi_irsa
  ]
}
# Pin to a specific ArgoCD release tag
data "http" "argocd_manifest" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.0/manifests/install.yaml"
}

data "kubectl_file_documents" "argocd" {
  content = data.http.argocd_manifest.response_body
}

resource "kubectl_manifest" "argocd" {
  for_each = {
    for doc in data.kubectl_file_documents.argocd.manifests :
    "${yamldecode(doc).kind}/${yamldecode(doc).metadata.name}" => doc
    if !(
      yamldecode(doc).kind == "Service" &&
      yamldecode(doc).metadata.name == "argocd-server"
    )
  }

  yaml_body          = each.value
  override_namespace = "argocd"
  wait_for_rollout   = true

  depends_on = [module.eks]
}

# Sole owner of argocd-server Service
resource "kubectl_manifest" "argocd_server_lb" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: argocd-server
      namespace: argocd
    spec:
      type: LoadBalancer
  YAML

  ignore_fields = ["spec.ports", "spec.selector", "spec.clusterIP"]

  depends_on = [kubectl_manifest.argocd]
}   
