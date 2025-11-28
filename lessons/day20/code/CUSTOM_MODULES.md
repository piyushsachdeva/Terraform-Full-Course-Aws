# Custom Modules - EKS Infrastructure

This Terraform configuration demonstrates custom module creation for EKS cluster deployment.

## Module Structure

```
modules/
├── vpc/              # Custom VPC module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── iam/              # Custom IAM roles module
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── eks/              # Custom EKS cluster module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── templates/
│       └── userdata.sh
└── secrets-manager/  # Custom Secrets Manager module
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Modules Overview

### 1. VPC Module (`modules/vpc/`)
Creates networking infrastructure:
- VPC with custom CIDR
- Public subnets (3 AZs) with Internet Gateway
- Private subnets (3 AZs) with NAT Gateway
- Route tables and associations
- EKS-required subnet tags

### 2. IAM Module (`modules/iam/`)
Creates IAM resources:
- EKS cluster IAM role with policies
- Node group IAM role with policies
- OIDC provider for IRSA (IAM Roles for Service Accounts)

### 3. EKS Module (`modules/eks/`)
Creates EKS cluster resources:
- EKS control plane with KMS encryption
- CloudWatch log group
- Security groups (cluster + nodes)
- EKS addons (CoreDNS, kube-proxy, VPC CNI)
- Managed node groups with launch templates
- Customizable node group configurations

### 4. Secrets Manager Module (`modules/secrets-manager/`)
Creates secrets management resources:
- KMS key for secrets encryption
- Database credentials secret (optional)
- API keys secret (optional)
- Application config secret (optional)
- IAM policy for reading secrets

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review the Plan
```bash
terraform plan
```

### 3. Apply Configuration
```bash
terraform apply
```

### 4. Configure kubectl
```bash
aws eks --region us-east-1 update-kubeconfig --name day20-eks
```

### 5. Verify Cluster
```bash
kubectl get nodes
kubectl get pods -A
```

## Module Features

### VPC Module Features
- Multi-AZ deployment (3 availability zones)
- Single NAT Gateway (cost optimization)
- Automatic subnet tagging for EKS
- IPv4 with DNS support

### EKS Module Features
- KMS encryption for secrets
- CloudWatch logging (all log types)
- Public + Private endpoint access
- IRSA enabled for pod IAM roles
- Custom launch templates with:
  - EBS encryption
  - IMDSv2 enforced
  - CloudWatch monitoring
  - Custom user data support

### IAM Module Features
- AWS managed policies attached
- OIDC provider for IRSA
- Separate roles for cluster and nodes
- Automatic policy attachments

### Secrets Manager Features
- Optional secret creation
- KMS encryption
- IAM policy for reading secrets
- Support for multiple secret types

## Customization

### Node Groups
Edit `main.tf` to customize node groups:
```hcl
node_groups = {
  general = {
    instance_types = ["t3.medium"]
    desired_size   = 2
    min_size       = 2
    max_size       = 4
    capacity_type  = "ON_DEMAND"
    disk_size      = 20
  }
}
```

### Secrets Manager (Optional)
Enable secrets in `terraform.tfvars`:
```hcl
enable_db_secret = true
db_username      = "admin"
db_password      = "SecurePass123!"
db_host          = "db.example.com"
db_name          = "myapp"
```

## Cleanup

```bash
# Delete Kubernetes resources first
kubectl delete svc --all
kubectl delete pods --all

# Destroy Terraform resources
terraform destroy
```

## Key Differences from Public Modules

| Aspect | Public Modules | Custom Modules |
|--------|----------------|----------------|
| **Control** | Limited customization | Full control over resources |
| **Learning** | Abstract complexity | Understand every resource |
| **Maintenance** | Community maintained | Self maintained |
| **Flexibility** | Pre-defined patterns | Custom patterns |
| **Transparency** | Need to read source | Code is local |

## Resources Created

- 1 VPC with 6 subnets
- 1 Internet Gateway
- 1 NAT Gateway (with Elastic IP)
- Route tables and associations
- EKS cluster with control plane
- 2 node groups (general + spot)
- Security groups for cluster and nodes
- IAM roles and policies
- OIDC provider for IRSA
- KMS keys for encryption
- CloudWatch log group
- Optional: Secrets Manager secrets

## Estimated Costs

- EKS Control Plane: ~$73/month
- t3.medium nodes (3): ~$90/month
- NAT Gateway: ~$32/month
- Data transfer: Variable
- **Total: ~$195/month**

## Best Practices Implemented

✅ Multi-AZ for high availability
✅ KMS encryption for secrets and EBS
✅ IMDSv2 enforced on nodes
✅ Private subnets for worker nodes
✅ Security groups with minimal permissions
✅ CloudWatch logging enabled
✅ IRSA for pod-level IAM permissions
✅ Spot instances for cost optimization
✅ Automated tagging

## Next Steps

1. Deploy applications using kubectl
2. Configure IRSA for application pods
3. Set up ingress controller (AWS LB Controller)
4. Configure monitoring (Prometheus/Grafana)
5. Implement GitOps (ArgoCD/FluxCD)
