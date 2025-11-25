# Day 20: EKS Cluster with Terraform

This configuration creates a production-ready Amazon EKS (Elastic Kubernetes Service) cluster using Terraform with the latest AWS Provider 6.x.

## Architecture

The setup includes:
- **VPC**: Custom VPC with public and private subnets across 3 availability zones
- **EKS Cluster**: Managed Kubernetes cluster with version 1.31
- **Node Groups**: 
  - General purpose node group (on-demand instances)
  - Spot instance node group for cost optimization
- **Add-ons**: CoreDNS, kube-proxy, VPC CNI, and EBS CSI driver
- **IRSA**: IAM Roles for Service Accounts enabled for fine-grained permissions

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** >= 1.3 installed
4. **kubectl** installed for cluster management
5. **aws-iam-authenticator** (optional, AWS CLI v1.16.156+ has built-in support)

## Resources Created

- VPC with 3 public and 3 private subnets
- Internet Gateway and NAT Gateway
- EKS Cluster with control plane
- 2 EKS Managed Node Groups (3 nodes total)
- Security Groups for cluster and nodes
- IAM roles and policies for EKS
- OIDC provider for IRSA

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

This will take approximately 10-15 minutes to complete.

### 4. Configure kubectl

After the cluster is created, configure kubectl to connect:

```bash
aws eks --region us-east-1 update-kubeconfig --name day20-eks-cluster
```

Or use the output command:

```bash
$(terraform output -raw configure_kubectl)
```

### 5. Verify the Cluster

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Check node status
kubectl get nodes -o wide

# Verify addons
kubectl get daemonsets -n kube-system
```

## Configuration Options

You can customize the cluster by modifying `terraform.tfvars`:

```hcl
aws_region         = "us-east-1"        # Change to your preferred region
cluster_name       = "day20-eks-cluster" # Your cluster name
kubernetes_version = "1.31"              # Kubernetes version
environment        = "development"       # Environment tag

# VPC settings
vpc_cidr        = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
```

## Key Features

### AWS Provider 6.x
- Enhanced multi-region support
- Improved resource handling
- Better error messages
- Latest AWS API features

### EKS Module 20.x
- Simplified node group configuration
- Native support for cluster addons
- Improved IRSA integration
- Better security group management

### Node Groups
- **General**: On-demand t3.medium instances for stable workloads
- **Spot**: Spot instances for cost-effective batch processing

### Security
- Private subnets for worker nodes
- Security groups with least privilege
- IAM roles with minimal required permissions
- IRSA enabled for pod-level permissions

## Outputs

The following outputs are available:

```bash
terraform output cluster_endpoint         # EKS API endpoint
terraform output cluster_name             # Cluster name
terraform output configure_kubectl        # kubectl config command
terraform output region                   # AWS region
terraform output vpc_id                   # VPC ID
```

## Managing the Cluster

### Scale Node Groups

Modify the node group configuration in `main.tf`:

```hcl
eks_managed_node_groups = {
  general = {
    min_size     = 2
    max_size     = 6
    desired_size = 3  # Change this value
  }
}
```

Then apply:

```bash
terraform apply
```

### Deploy Applications

```bash
# Deploy a sample nginx application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check the service
kubectl get svc nginx
```

### View Cluster Logs

```bash
# View cluster logs in CloudWatch
aws eks describe-cluster --name day20-eks-cluster --query cluster.logging
```

## Cost Optimization

- Uses single NAT Gateway (can be changed to one per AZ for HA)
- Includes spot instance node group
- Right-sized instance types (t3.medium)

**Estimated Cost**: ~$0.10/hour for EKS control plane + EC2 instances (~$0.04-0.06/hour)

⚠️ **Warning**: Remember to destroy resources when not in use to avoid charges!

## Cleanup

To destroy all resources:

```bash
# First, delete any LoadBalancer services to clean up AWS load balancers
kubectl delete svc --all

# Then destroy Terraform resources
terraform destroy
```

## Troubleshooting

### Cannot connect to cluster
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Update kubeconfig
aws eks --region us-east-1 update-kubeconfig --name day20-eks-cluster
```

### Nodes not joining cluster
```bash
# Check node group status
aws eks describe-nodegroup --cluster-name day20-eks-cluster --nodegroup-name <node-group-name>

# Check cluster security group
aws eks describe-cluster --name day20-eks-cluster --query cluster.resourcesVpcConfig.clusterSecurityGroupId
```

### Insufficient capacity
If you get capacity errors, try:
- Different instance types
- Different availability zones
- Use spot instances

## Next Steps

- Deploy applications to the cluster
- Set up monitoring with CloudWatch Container Insights
- Configure cluster autoscaler
- Implement CI/CD pipelines
- Set up ingress controller (ALB/NGINX)
- Configure persistent storage with EBS/EFS

## References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Support

For issues or questions:
1. Check AWS EKS documentation
2. Review Terraform AWS provider changelog
3. Consult the EKS module GitHub repository
