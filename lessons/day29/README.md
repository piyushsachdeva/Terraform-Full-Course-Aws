# Day 29: GitOps with ArgoCD in EKS Cluster with Kustomize

This project demonstrates a complete GitOps workflow using ArgoCD and Kustomize to deploy a 3-tier web application on AWS EKS.

## Architecture

The project consists of:
- **Frontend**: React application (port 3000)
- **Backend**: Node.js API (port 8080)
- **Database**: PostgreSQL (port 5432)

## Project Structure

```
day29/
├── terraform/          # Infrastructure as Code
│   ├── terraform.tf    # Terraform and provider requirements
│   ├── providers.tf    # Provider configurations
│   ├── variables.tf    # Input variables
│   ├── main.tf         # Main resources (VPC, EKS, ArgoCD)
│   └── outputs.tf      # Output values
└── manifests/          # Kubernetes manifests
    ├── kustomization.yaml      # Kustomize configuration
    ├── namespace.yaml          # Namespace definition
    ├── secret.yaml             # Postgres credentials
    ├── postgres.yaml           # Database deployment
    ├── backend.yaml            # Backend API deployment
    ├── frontend.yaml           # Frontend deployment
    └── argocd-app.yaml         # ArgoCD Application manifest
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- kubectl
- kustomize (optional, built into kubectl)

## Technical Highlights

### 1. Latest Provider & Module Versions (2026)

- **AWS Provider**: `6.x` (Latest major version)
- **EKS Module**: `21.x` (Latest major version with breaking changes handled)
- **Helm Provider**: `3.x` (New syntax implemented)
- **Kubernetes Provider**: `3.x`

### 2. EKS Module v21 Updates

This project uses the latest `terraform-aws-modules/eks/aws` v21 syntax:
- `cluster_name` → `name`
- `cluster_version` → `kubernetes_version`
- `cluster_endpoint_public_access` → `endpoint_public_access`
- `aws-auth` removed in favor of Access Entries (API authentication)

### 3. Helm Provider v3+ Syntax


### 1. Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

This will create:
- VPC with public and private subnets
- EKS cluster with managed node groups
- ArgoCD installed via Helm

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name gitops-eks-cluster
```

### 3. Get ArgoCD Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Access ArgoCD UI

```bash
# Get the LoadBalancer URL
kubectl get svc argocd-server -n argocd

# Or use port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Visit: `https://localhost:8080`
- Username: `admin`
- Password: (from step 3)

### 5. Deploy the Application

**Option A: Using ArgoCD UI**
- Create a new application using the `manifests/argocd-app.yaml` configuration

**Option B: Using kubectl**
```bash
kubectl apply -f manifests/argocd-app.yaml
```

ArgoCD will automatically sync and deploy the application.

### 6. Access the Application

```bash
# Get the frontend LoadBalancer URL
kubectl get svc frontend -n 3tirewebapp-dev
```

## Kustomize Features

The `kustomization.yaml` file demonstrates:
- **Namespace management**: All resources deployed to `3tirewebapp-dev`
- **Image management**: Centralized image tags
- **Replica management**: Control replicas from one place
- **Common annotations**: Applied to all resources

To view the rendered manifests:
```bash
kubectl kustomize manifests/
```

## Scaling

To scale the application, edit `manifests/kustomization.yaml`:

```yaml
replicas:
  - name: frontend
    count: 3  # Scale to 3 replicas
  - name: backend
    count: 3
```

Commit and push changes. ArgoCD will automatically sync.

## Clean Up

```bash
# Delete the application
kubectl delete -f manifests/argocd-app.yaml

# Destroy infrastructure
cd terraform
terraform destroy
```

## GitOps Workflow

1. **Developers** push code changes to application repositories
2. **CI/CD** builds new container images with tags
3. **Update** `manifests/kustomization.yaml` with new image tags
4. **ArgoCD** automatically detects changes and syncs to cluster
5. **Kubernetes** performs rolling updates

## Notes

- The PostgreSQL credentials are stored in a Kubernetes Secret for demonstration purposes
- For production, consider using AWS Secrets Manager with External Secrets Operator
- The frontend service uses LoadBalancer type for easy access
- ArgoCD is configured with auto-sync and self-healing enabled

## Troubleshooting

### Check ArgoCD Application Status
```bash
kubectl get application -n argocd
```

### View Application Logs
```bash
# Backend
kubectl logs -f deployment/backend -n 3tirewebapp-dev

# Frontend
kubectl logs -f deployment/frontend -n 3tirewebapp-dev

# Postgres
kubectl logs -f deployment/postgres -n 3tirewebapp-dev
```

### Sync Manually
```bash
argocd app sync 3tier-app
```