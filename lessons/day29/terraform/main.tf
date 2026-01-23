data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

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
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      subnet_ids = module.vpc.private_subnets
    }
  }

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# EBS CSI Driver IAM Role
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# ArgoCD Namespace
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.eks]
}

# Install ArgoCD using kubectl provider
data "http" "argocd_manifest" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}

resource "kubectl_manifest" "argocd" {
  for_each = { for doc in split("---", data.http.argocd_manifest.response_body) : 
    sha256(doc) => doc if trimspace(doc) != "" 
  }

  yaml_body = each.value
  override_namespace = "argocd"

  depends_on = [kubernetes_namespace_v1.argocd]
}

# Patch ArgoCD server service to LoadBalancer
resource "null_resource" "patch_argocd_service" {
  provisioner "local-exec" {
    command = <<-EOT
      # Update kubeconfig first
      aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}
      
      # Wait a bit for service to be created
      sleep 10
      
      # Patch service to LoadBalancer (ignore errors if already patched)
      kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' || true
    EOT
  }

  depends_on = [kubectl_manifest.argocd]
}

# Application namespace - managed by ArgoCD Application manifest
# Commenting out to avoid stuck namespace during destroy
# The namespace is created by ArgoCD from the GitOps repository
# resource "kubernetes_namespace_v1" "app" {
#   metadata {
#     name = "3tirewebapp-dev"
#   }
#   depends_on = [module.eks]
# }

# Deploy application via ArgoCD Application CRD
resource "kubectl_manifest" "app_deployment" {
  yaml_body = file("${path.module}/../manifests/argocd-app.yaml")

  depends_on = [kubectl_manifest.argocd]
}
