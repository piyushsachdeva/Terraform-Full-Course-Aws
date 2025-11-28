# EKS Custom Modules - Complete Demo Guide

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Custom Modules Explained](#custom-modules-explained)
4. [Resources Provisioned](#resources-provisioned)
5. [Component Purpose & Dependencies](#component-purpose--dependencies)
6. [Step-by-Step Deployment](#step-by-step-deployment)
7. [Verification & Testing](#verification--testing)
8. [Cost Breakdown](#cost-breakdown)
9. [Cleanup](#cleanup)

---

## 🎯 Project Overview

This project demonstrates **production-ready EKS cluster deployment** using **custom Terraform modules** instead of public community modules. The infrastructure showcases enterprise-level practices including:

- ✅ **Full infrastructure ownership** - Every resource is defined in custom modules
- ✅ **Multi-AZ high availability** - 3 availability zones for fault tolerance
- ✅ **Security best practices** - KMS encryption, IRSA, private subnets
- ✅ **Cost optimization** - Single NAT Gateway, Spot instances
- ✅ **Modular design** - Reusable modules for VPC, IAM, EKS, Secrets Manager

### Why Custom Modules?

| Aspect | Public Modules | Custom Modules (This Project) |
|--------|----------------|-------------------------------|
| **Control** | Limited | ✅ Full control over every resource |
| **Learning** | Abstract complexity | ✅ Learn exactly how EKS works |
| **Customization** | Pre-defined patterns | ✅ Tailor to your needs |
| **Transparency** | Need to read source code | ✅ All code is local & clear |
| **Enterprise Use** | Version dependencies | ✅ Self-maintained, no surprises |

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (us-east-1)                             │
│                                                                             │
│  Internet ──────────────────────────────────────────────────┐               │
│                                                             │               │
│  ┌──────────────────────────────────────────────────────────▼────────────┐  │
│  │                        VPC (10.0.0.0/16)                              │  │
│  │                                                                        │  │
│  │  ┌────────────────────────────┐    ┌─────────────────────────────┐    │  │
│  │  │   PUBLIC SUBNETS (3 AZs)   │    │  PRIVATE SUBNETS (3 AZs)    │    │  │
│  │  │  ┌──────────────────────┐  │    │  ┌───────────────────────┐  │    │  │
│  │  │  │ Internet Gateway     │  │    │  │   EKS Cluster v1.31   │  │    │  │
│  │  │  │ (IGW)               │  │    │  │                       │  │    │  │
│  │  │  └──────────┬───────────┘  │    │  │  ┌─────────────────┐  │  │    │  │
│  │  │             │              │    │  │  │ Control Plane   │  │  │    │  │
│  │  │  ┌──────────▼───────────┐  │    │  │  │ (AWS Managed)   │  │  │    │  │
│  │  │  │  NAT Gateway        │──┼────┼──┼─►└─────────────────┘  │  │    │  │
│  │  │  │  (with Elastic IP)  │  │    │  │                       │  │    │  │
│  │  │  └─────────────────────┘  │    │  │  ┌─────────────────┐  │  │    │  │
│  │  │                            │    │  │  │ Worker Nodes    │  │  │    │  │
│  │  │  10.0.101.0/24             │    │  │  │ • General (2)   │  │  │    │  │
│  │  │  10.0.102.0/24             │    │  │  │ • Spot (1)      │  │  │    │  │
│  │  │  10.0.103.0/24             │    │  │  └─────────────────┘  │  │    │  │
│  │  └────────────────────────────┘    │  │                       │  │    │  │
│  │                                    │  │  ┌─────────────────┐  │  │    │  │
│  │                                    │  │  │ Security Groups │  │  │    │  │
│  │                                    │  │  │ • Cluster SG    │  │  │    │  │
│  │                                    │  │  │ • Node SG       │  │  │    │  │
│  │                                    │  │  └─────────────────┘  │  │    │  │
│  │                                    │  │                       │  │    │  │
│  │                                    │  │  10.0.1.0/24          │  │    │  │
│  │                                    │  │  10.0.2.0/24          │  │    │  │
│  │                                    │  │  10.0.3.0/24          │  │    │  │
│  │                                    │  └───────────────────────┘  │    │  │
│  └────────────────────────────────────────────────────────────────┘    │  │
│                                                                         │  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────────┐   │  │
│  │   IAM Roles     │  │   KMS Keys      │  │   CloudWatch Logs    │   │  │
│  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌────────────────┐  │   │  │
│  │  │ Cluster   │──┼──┼─►│ EKS Key   │──┼──┼─►│ /aws/eks/...   │  │   │  │
│  │  │ Role      │  │  │  └───────────┘  │  │  └────────────────┘  │   │  │
│  │  └───────────┘  │  │                 │  │                      │   │  │
│  │  ┌───────────┐  │  │  ┌───────────┐  │  │                      │   │  │
│  │  │ Node      │  │  │  │ Secrets   │  │  │                      │   │  │
│  │  │ Role      │  │  │  │ Key       │  │  │                      │   │  │
│  │  └───────────┘  │  │  └───────────┘  │  │                      │   │  │
│  │  ┌───────────┐  │  │                 │  │                      │   │  │
│  │  │ OIDC      │  │  │                 │  │                      │   │  │
│  │  │ Provider  │  │  │                 │  │                      │   │  │
│  │  └───────────┘  │  │                 │  │                      │   │  │
│  └─────────────────┘  └─────────────────┘  └──────────────────────┘   │  │
│                                                                         │  │
│  ┌──────────────────────────────────────────────────────────────────┐   │  │
│  │              Secrets Manager (Optional - Not Deployed)           │   │  │
│  │  • Database Credentials  • API Keys  • App Configuration         │   │  │
│  └──────────────────────────────────────────────────────────────────┘   │  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Traffic Flow

1. **Internet → IGW** - External traffic enters through Internet Gateway
2. **IGW → Public Subnets** - Routed to public subnets
3. **Public Subnets → NAT Gateway** - Outbound traffic from private subnets
4. **NAT → Private Subnets** - NAT translates private IPs to public
5. **Private Subnets → EKS** - Kubernetes nodes communicate internally
6. **EKS → Internet** - Pods reach internet via NAT Gateway

---

## 📦 Custom Modules Explained

### Module 1: VPC Module (`modules/vpc/`)

**Purpose:** Creates the networking foundation for EKS cluster.

**Why We Need It:**
- EKS requires specific VPC configuration with public and private subnets
- Proper subnet tagging is critical for Kubernetes service discovery
- NAT Gateway enables private nodes to access internet (for pulling images, updates)

**Resources Created:**
- 1 VPC (10.0.0.0/16)
- 3 Public Subnets (across 3 AZs)
- 3 Private Subnets (across 3 AZs)
- 1 Internet Gateway
- 1 NAT Gateway (cost optimization - single NAT)
- 1 Elastic IP (for NAT Gateway)
- Route Tables (public + private)
- Route Table Associations

**Key Features:**
```hcl
# Automatic EKS subnet tagging
public_subnet_tags = {
  "kubernetes.io/role/elb" = "1"  # For public load balancers
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = "1"  # For internal LBs
}
```

**Why These Components:**
- **Internet Gateway:** Required for public subnet internet access
- **NAT Gateway:** Allows private subnets (EKS nodes) to reach internet without exposing them
- **Multiple AZs:** High availability - if one AZ fails, others continue working
- **Subnet Tagging:** Kubernetes uses these tags to automatically create load balancers

---

### Module 2: IAM Module (`modules/iam/`)

**Purpose:** Creates IAM roles and policies for EKS cluster and worker nodes.

**Why We Need It:**
- EKS control plane needs permissions to manage AWS resources
- Worker nodes need permissions to join cluster and run workloads
- OIDC enables pods to assume IAM roles (IRSA - IAM Roles for Service Accounts)

**Resources Created:**
- EKS Cluster IAM Role
- EKS Node Group IAM Role
- IAM Policy Attachments (AWS managed policies)
  - `AmazonEKSClusterPolicy`
  - `AmazonEKSVPCResourceController`
  - `AmazonEKSWorkerNodePolicy`
  - `AmazonEKS_CNI_Policy`
  - `AmazonEC2ContainerRegistryReadOnly`

**Why These Components:**
- **Cluster Role:** EKS control plane needs to create/manage load balancers, security groups
- **Node Role:** Worker nodes need to pull container images, register with cluster
- **Separate Roles:** Principle of least privilege - different permissions for different components

**How It Works:**
```
EKS Cluster → Assumes Cluster Role → Creates Load Balancers, Security Groups
Worker Nodes → Assumes Node Role → Pulls Images, Joins Cluster, Runs Pods
```

---

### Module 3: EKS Module (`modules/eks/`)

**Purpose:** Creates the Kubernetes cluster and worker nodes.

**Why We Need It:**
- Provisions the actual Kubernetes control plane
- Creates managed node groups (worker nodes)
- Configures cluster security, logging, and encryption

**Resources Created:**

**Control Plane:**
- EKS Cluster
- KMS Key (for etcd encryption)
- CloudWatch Log Group (cluster logs)
- Cluster Security Group

**Worker Nodes:**
- 2 Node Groups (general + spot)
- Launch Templates (with custom configurations)
- Node Security Group

**Add-ons:**
- CoreDNS (DNS for Kubernetes)
- kube-proxy (Network proxy)
- VPC CNI (AWS networking for pods)

**IRSA (IAM Roles for Service Accounts):**
- OIDC Provider (enables pod-level IAM permissions)

**Why These Components:**

1. **KMS Encryption:**
   ```hcl
   encryption_config {
     resources = ["secrets"]  # Encrypts Kubernetes secrets in etcd
   }
   ```
   - **Why:** Kubernetes secrets contain sensitive data (passwords, tokens)
   - **Benefit:** Even if someone accesses etcd database, secrets are encrypted

2. **CloudWatch Logs:**
   ```hcl
   enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
   ```
   - **Why:** Monitor cluster health, troubleshoot issues, security audits
   - **Benefit:** Centralized logging for debugging and compliance

3. **Security Groups:**
   - **Cluster SG:** Controls traffic to/from control plane
   - **Node SG:** Controls traffic to/from worker nodes
   - **Why:** Network-level security, restrict unauthorized access

4. **Node Groups:**
   - **General (ON_DEMAND):** Stable, always-available nodes for critical workloads
   - **Spot (SPOT):** 90% cheaper, but can be terminated - for batch jobs
   - **Why:** Cost optimization while maintaining reliability

5. **Launch Templates:**
   ```hcl
   metadata_options {
     http_tokens = "required"  # IMDSv2 enforced
   }
   
   ebs {
     encrypted = true  # All volumes encrypted
   }
   ```
   - **Why:** Security hardening, encryption at rest
   - **Benefit:** Protects against metadata service attacks

6. **OIDC Provider:**
   - **Why:** Enables Kubernetes pods to assume IAM roles
   - **Example:** Pod needs to access S3 bucket - instead of storing AWS keys, pod assumes IAM role
   - **Benefit:** No credentials in code, better security

---

### Module 4: Secrets Manager (`modules/secrets-manager/`)

**Purpose:** Securely store and manage application secrets.

**⚠️ IMPORTANT: This Module is NOT Deployed by Default**

**Current Status:** ❌ **DISABLED** (0 resources created)

**Why It Exists:**
- Demonstrates how to build a custom Secrets Manager module
- Shows conditional resource creation pattern (`count = var.enable_db_secret ? 1 : 0`)
- Provides a template for future use when you add databases or external services
- Included in Day 20 learning objectives: "Custom module creation for Secrets Manager"

**What It WOULD Create (if enabled):**
- KMS Key (for secrets encryption)
- Database Credentials Secret
- API Keys Secret
- Application Config Secret
- IAM Policy (for reading secrets)

**Why These Components Would Help:**

1. **KMS Encryption:**
   ```hcl
   enable_key_rotation = true  # Automatic annual rotation
   ```
   - **Why:** Secrets would be encrypted at rest
   - **Benefit:** Even AWS employees can't read your secrets without the key

2. **Secret Versioning:**
   - **Why:** Track changes, rollback if needed
   - **Benefit:** Audit trail, safe updates

3. **Recovery Window:**
   ```hcl
   recovery_window_in_days = 7
   ```
   - **Why:** Protection against accidental deletion
   - **Benefit:** Can recover deleted secrets within 7 days

4. **IAM Policy:**
   - **Why:** Control which applications can read which secrets
   - **Benefit:** Principle of least privilege

**How to Enable (for future use):**

```hcl
# Step 1: Deploy a database first (not included in this demo)
module "rds" {
  source = "./modules/rds"
  # ... RDS configuration
}

# Step 2: Enable secrets in terraform.tfvars
enable_db_secret = true
db_username      = "admin"
db_password      = "YourSecurePassword123!"
db_host          = module.rds.endpoint  # From your database
db_port          = 5432
db_name          = "myapp"

# Step 3: Apply
terraform apply
```

**What About Secrets in the Current Setup?**

Even though AWS Secrets Manager is disabled, the EKS cluster DOES encrypt Kubernetes secrets:

```hcl
# modules/eks/main.tf
encryption_config {
  resources = ["secrets"]  # Kubernetes secrets encrypted with KMS
}
```

**Example of Kubernetes Secret (encrypted by EKS KMS key):**
```bash
# Create a Kubernetes secret
kubectl create secret generic my-app-secret \
  --from-literal=api-key=abc123

# This secret is automatically encrypted in etcd using the KMS key
```

**Cost Impact:**
- Current setup: $0 (not deployed)
- If enabled: ~$2-3/month (1 KMS key + secrets storage)

**Note:** This is an optional module for demonstration purposes. The infrastructure works perfectly without it since there's no database or external APIs requiring secret storage.

---

## 📊 Resources Provisioned

### Complete Resource List (44 Resources)

**Note:** The Secrets Manager module is included in the code but NOT deployed (0 resources). Only VPC, IAM, and EKS modules are active.

#### VPC Module (18 resources)
```
✅ aws_vpc.main                              # VPC
✅ aws_internet_gateway.main                 # Internet Gateway
✅ aws_eip.nat[0]                           # Elastic IP for NAT
✅ aws_nat_gateway.main[0]                  # NAT Gateway
✅ aws_subnet.public[0]                     # Public Subnet 1
✅ aws_subnet.public[1]                     # Public Subnet 2
✅ aws_subnet.public[2]                     # Public Subnet 3
✅ aws_subnet.private[0]                    # Private Subnet 1
✅ aws_subnet.private[1]                    # Private Subnet 2
✅ aws_subnet.private[2]                    # Private Subnet 3
✅ aws_route_table.public                   # Public Route Table
✅ aws_route.public_internet_gateway        # Route to IGW
✅ aws_route_table_association.public[0]    # Public RT Association 1
✅ aws_route_table_association.public[1]    # Public RT Association 2
✅ aws_route_table_association.public[2]    # Public RT Association 3
✅ aws_route_table.private[0]               # Private Route Table
✅ aws_route.private_nat_gateway[0]         # Route to NAT
✅ aws_route_table_association.private[0]   # Private RT Association 1
✅ aws_route_table_association.private[1]   # Private RT Association 2
✅ aws_route_table_association.private[2]   # Private RT Association 3
```

#### IAM Module (8 resources)
```
✅ aws_iam_role.cluster                                    # EKS Cluster Role
✅ aws_iam_role_policy_attachment.cluster_policy          # Cluster Policy 1
✅ aws_iam_role_policy_attachment.cluster_vpc_controller  # Cluster Policy 2
✅ aws_iam_role.node_group                                # Node Group Role
✅ aws_iam_role_policy_attachment.node_worker_policy      # Node Policy 1
✅ aws_iam_role_policy_attachment.node_cni_policy         # Node Policy 2
✅ aws_iam_role_policy_attachment.node_registry_policy    # Node Policy 3
```

#### EKS Module (18 resources)
```
✅ aws_kms_key.eks                          # KMS Key for EKS
✅ aws_kms_alias.eks                        # KMS Alias
✅ aws_cloudwatch_log_group.eks             # CloudWatch Log Group
✅ aws_security_group.cluster               # Cluster Security Group
✅ aws_security_group.node                  # Node Security Group
✅ aws_security_group_rule.node_to_cluster  # SG Rule 1
✅ aws_security_group_rule.cluster_to_node  # SG Rule 2
✅ aws_security_group_rule.node_to_node     # SG Rule 3
✅ aws_eks_cluster.main                     # EKS Cluster
✅ aws_iam_openid_connect_provider.cluster  # OIDC Provider
✅ aws_eks_addon.coredns                    # CoreDNS Addon
✅ aws_eks_addon.kube_proxy                 # kube-proxy Addon
✅ aws_eks_addon.vpc_cni                    # VPC CNI Addon
✅ aws_launch_template.node["general"]      # General Launch Template
✅ aws_launch_template.node["spot"]         # Spot Launch Template
✅ aws_eks_node_group.main["general"]       # General Node Group
✅ aws_eks_node_group.main["spot"]          # Spot Node Group
```

#### Secrets Manager Module (0 resources - DISABLED)
```
❌ aws_kms_key.secrets[0]                              # NOT created (count = 0)
❌ aws_kms_alias.secrets[0]                            # NOT created (count = 0)
❌ aws_secretsmanager_secret.db_credentials[0]         # NOT created (count = 0)
❌ aws_secretsmanager_secret_version.db_credentials[0] # NOT created (count = 0)
❌ aws_secretsmanager_secret.api_keys[0]               # NOT created (count = 0)
❌ aws_secretsmanager_secret_version.api_keys[0]       # NOT created (count = 0)
❌ aws_secretsmanager_secret.app_config[0]             # NOT created (count = 0)
❌ aws_secretsmanager_secret_version.app_config[0]     # NOT created (count = 0)
❌ aws_iam_policy.read_secrets[0]                      # NOT created (count = 0)
```

**Reason:** All Secrets Manager resources use conditional creation:
```hcl
count = var.enable_db_secret || var.enable_api_secret || var.enable_app_config_secret ? 1 : 0
```
Since all three flags are `false`, count evaluates to `0`, and no resources are created.

**Total:** 44 active resources (VPC + IAM + EKS only)

---

## 🔗 Component Purpose & Dependencies

### Dependency Chain

```
1. VPC Module
   ↓ (provides: vpc_id, subnet_ids)
2. IAM Module
   ↓ (provides: cluster_role_arn, node_role_arn)
3. EKS Module
   ↓ (uses: vpc_id, subnet_ids, IAM roles)
   ↓ (creates: OIDC provider, KMS key for K8s secrets)
4. Secrets Manager Module (NOT DEPLOYED)
   ❌ (disabled - would be used by pods via IRSA + OIDC if enabled)
```

**Active Deployment:**
- ✅ VPC → IAM → EKS
- ❌ Secrets Manager (code exists but not deployed)

### How Components Work Together

#### Example: Pod Accessing S3 Bucket

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Pod wants to access S3 bucket                                │
│    ↓                                                             │
│ 2. Pod uses Kubernetes Service Account with annotation          │
│    eks.amazonaws.com/role-arn: arn:aws:iam::...:role/s3-reader  │
│    ↓                                                             │
│ 3. EKS OIDC Provider validates the service account              │
│    ↓                                                             │
│ 4. AWS STS issues temporary credentials                         │
│    ↓                                                             │
│ 5. Pod uses temporary credentials to access S3                  │
│    ↓                                                             │
│ 6. Success! Pod reads/writes to S3 without storing AWS keys     │
└─────────────────────────────────────────────────────────────────┘
```

#### Example: User Accessing Application

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User visits website (app.example.com)                        │
│    ↓                                                             │
│ 2. DNS resolves to AWS Load Balancer (in public subnet)         │
│    ↓                                                             │
│ 3. Load Balancer forwards to EKS Service (internal)             │
│    ↓                                                             │
│ 4. Service routes to Pod on worker node (in private subnet)     │
│    ↓                                                             │
│ 5. Pod processes request, may access RDS/S3                     │
│    ↓                                                             │
│ 6. Response returns through Load Balancer to user               │
└─────────────────────────────────────────────────────────────────┘
```

### Why Each Layer Matters

| Layer | Purpose | Without It... |
|-------|---------|---------------|
| **VPC** | Network isolation | No place to deploy resources |
| **Public Subnets** | Internet-facing resources | Can't receive external traffic |
| **Private Subnets** | Protected workloads | Nodes exposed to internet |
| **IGW** | Public internet access | Public subnets can't reach internet |
| **NAT** | Private internet access | Nodes can't pull images/updates |
| **IAM Roles** | AWS permissions | Nodes/pods can't access AWS services |
| **Security Groups** | Network firewall | Unrestricted access (security risk) |
| **KMS** | Data encryption | Secrets stored in plain text |
| **OIDC** | Pod-level IAM | Need to hardcode AWS credentials |
| **CloudWatch** | Logging & monitoring | No visibility into cluster health |

---

## 🚀 Step-by-Step Deployment

### Prerequisites

```bash
# Check prerequisites
aws --version        # AWS CLI v2.x
terraform --version  # Terraform >= 1.3
kubectl version      # kubectl v1.31
```

### Step 1: Clone & Navigate

```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day20/code
```

### Step 2: Review Configuration

```bash
# Review variables
cat variables.tf

# Review main configuration
cat main.tf

# Check module structure
tree modules/
```

### Step 3: Initialize Terraform

```bash
terraform init
```

**What happens:**
- Downloads AWS provider plugin
- Initializes backend (local state)
- Prepares modules

### Step 4: Validate Configuration

```bash
terraform validate
```

**Expected output:**
```
Success! The configuration is valid.
```

### Step 5: Plan Deployment

```bash
terraform plan
```

**What to look for:**
```
Plan: 44 to add, 0 to change, 0 to destroy.
```

**Review the plan carefully:**
- Check resource names
- Verify CIDR blocks
- Confirm costs

### Step 6: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**What Gets Created:**
```
✅ VPC Module: 18 resources (VPC, subnets, IGW, NAT, routes)
✅ IAM Module: 8 resources (roles, policies)
✅ EKS Module: 18 resources (cluster, nodes, security groups, OIDC)
❌ Secrets Manager: 0 resources (disabled)
───────────────────────────────
Total: 44 resources
```

**Timeline:**
```
00:00 - Starting...
01:30 - VPC created (18 resources)
03:00 - IAM roles created (8 resources)
10:00 - EKS cluster creating (this takes time)
15:00 - Node groups creating
25:00 - Complete! ✅ (44 resources deployed)
```

### Step 7: Configure kubectl

```bash
# Get the command from Terraform output
terraform output configure_kubectl

# Or run directly
aws eks --region us-east-1 update-kubeconfig --name day20-eks
```

**What this does:**
- Adds EKS cluster to ~/.kube/config
- Configures authentication

---

## ✅ Verification & Testing

### 1. Verify Cluster Access

```bash
kubectl cluster-info
```

**Expected output:**
```
Kubernetes control plane is running at https://xxxxx.eks.us-east-1.amazonaws.com
CoreDNS is running at https://xxxxx.eks.us-east-1.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### 2. Check Nodes

```bash
kubectl get nodes
```

**Expected output:**
```
NAME                         STATUS   ROLES    AGE   VERSION
ip-10-0-1-xxx.ec2.internal   Ready    <none>   5m    v1.31.x
ip-10-0-2-xxx.ec2.internal   Ready    <none>   5m    v1.31.x
ip-10-0-3-xxx.ec2.internal   Ready    <none>   5m    v1.31.x
```

**Verify:**
- ✅ 3 nodes total (2 general + 1 spot)
- ✅ All nodes in Ready status
- ✅ Correct Kubernetes version

### 3. Check Add-ons

```bash
kubectl get pods -n kube-system
```

**Expected output:**
```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-xxxxx              1/1     Running   0          10m
coredns-xxxxx              1/1     Running   0          10m
aws-node-xxxxx             2/2     Running   0          5m
aws-node-xxxxx             2/2     Running   0          5m
kube-proxy-xxxxx           1/1     Running   0          5m
```

**Verify:**
- ✅ CoreDNS pods running (2 replicas)
- ✅ VPC CNI (aws-node) running on each node
- ✅ kube-proxy running on each node

### 4. Test Workload Deployment

```bash
# Deploy test nginx app
kubectl create deployment nginx --image=nginx:latest

# Check deployment
kubectl get deployments

# Check pods
kubectl get pods

# Expose as service
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service (wait for EXTERNAL-IP)
kubectl get svc nginx -w
```

**Expected flow:**
```
1. Pod scheduled on worker node ✅
2. Image pulled from Docker Hub (via NAT) ✅
3. Load Balancer created in public subnet ✅
4. External IP assigned ✅
5. Can access nginx via LoadBalancer URL ✅
```

### 5. Verify IAM/OIDC (IRSA)

```bash
# Check OIDC provider
aws iam list-open-id-connect-providers

# Create test service account with IAM role
kubectl create sa test-sa
kubectl annotate sa test-sa \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT:role/test-role

# Verify
kubectl describe sa test-sa
```

### 6. Check Logs

```bash
# View cluster logs in CloudWatch
aws logs tail /aws/eks/day20-eks/cluster --follow

# Or via AWS Console:
# CloudWatch → Log Groups → /aws/eks/day20-eks/cluster
```

### 7. Verify Encryption

```bash
# Check cluster encryption config
aws eks describe-cluster --name day20-eks \
  --query 'cluster.encryptionConfig'

# Expected output:
{
  "resources": ["secrets"],
  "provider": {
    "keyArn": "arn:aws:kms:us-east-1:xxx:key/xxx"
  }
}
```

### 8. Test Node Groups

```bash
# Check node groups
aws eks list-nodegroups --cluster-name day20-eks

# Describe node group
aws eks describe-nodegroup \
  --cluster-name day20-eks \
  --nodegroup-name general

# Verify spot instances
kubectl get nodes -o json | \
  jq '.items[] | {name:.metadata.name, capacity:.status.capacity}'
```

---

## 💰 Cost Breakdown

### Monthly Costs (us-east-1)

| Component | Cost | Calculation |
|-----------|------|-------------|
| **EKS Control Plane** | $73.00 | $0.10/hour × 730 hours |
| **EC2 Instances** | | |
| └─ General (2x t3.medium) | $60.74 | 2 × $0.0416/hour × 730 hours |
| └─ Spot (1x t3.medium) | $12.41 | 1 × $0.017/hour × 730 hours (70% savings) |
| **NAT Gateway** | | |
| └─ Hourly charge | $32.85 | $0.045/hour × 730 hours |
| └─ Data processing | ~$5-20 | $0.045/GB (varies by usage) |
| **EBS Volumes (60GB total)** | $6.00 | 60 GB × $0.10/GB-month |
| **Data Transfer** | ~$5-10 | First 100GB free, then $0.09/GB |
| **KMS Keys (2)** | $2.00 | 2 × $1/month |
| **CloudWatch Logs** | ~$2-5 | $0.50/GB ingested |
| **Load Balancer** (if created) | $16.20 | $0.0225/hour × 730 hours |
| | | |
| **Total (without LB)** | **~$195-225/month** | |
| **Total (with LB)** | **~$211-241/month** | |

### Cost Optimization Strategies

✅ **Already Implemented:**
- Single NAT Gateway (saves ~$65/month vs 3 NAT Gateways)
- Spot instances for non-critical workloads (saves ~$18/month)
- Right-sized instances (t3.medium sufficient for dev/test)
- Secrets Manager disabled by default (saves ~$1.20/month)

🔧 **Additional Savings (optional):**
- Use Fargate for some workloads (no EC2 costs, pay per pod)
- Schedule non-prod clusters to stop at night (save 50%)
- Use Reserved Instances for production (save 40-60%)
- Enable Cluster Autoscaler to scale down when idle

### Free Tier Eligible

- First 20,000 KMS requests/month
- First 100GB data transfer out/month
- First 5GB CloudWatch Logs ingested/month

---

## 🧹 Cleanup

### Important: Delete Resources in Order

#### Step 1: Delete Kubernetes Services (LoadBalancers)

```bash
# This deletes AWS Load Balancers created by Kubernetes
kubectl delete svc --all

# Wait for LBs to be deleted
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?VpcId==`vpc-xxx`].LoadBalancerArn'
```

**Why:** Terraform doesn't know about Kubernetes-created LBs. If not deleted, they'll remain after `terraform destroy`.

#### Step 2: Delete Kubernetes Deployments/Pods

```bash
kubectl delete deployments --all
kubectl delete pods --all
```

#### Step 3: Destroy Terraform Resources

```bash
terraform destroy
```

Type `yes` when prompted.

**Timeline:**
```
00:00 - Starting destruction...
05:00 - Node groups deleting
15:00 - EKS cluster deleting
18:00 - NAT Gateway deleting
20:00 - VPC resources deleting
22:00 - Complete! ✅
```

#### Step 4: Verify Cleanup

```bash
# Check no EKS clusters
aws eks list-clusters

# Check no EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:kubernetes.io/cluster/day20-eks,Values=owned" \
  --query 'Reservations[].Instances[].InstanceId'

# Check no NAT Gateways
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available"

# Check CloudWatch logs (optional - can keep for auditing)
aws logs describe-log-groups --log-group-name-prefix /aws/eks/day20
```

#### Step 5: Check for Orphaned Resources

```bash
# Check for lingering security groups
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=vpc-xxx" \
  --query 'SecurityGroups[?GroupName!=`default`].GroupId'

# Check for lingering ENIs
aws ec2 describe-network-interfaces \
  --filters "Name=vpc-id,Values=vpc-xxx"
```

**If found, delete manually:**
```bash
aws ec2 delete-security-group --group-id sg-xxx
aws ec2 delete-network-interface --network-interface-id eni-xxx
```

---

## 🎓 Learning Outcomes

After completing this demo, you understand:

✅ **Infrastructure as Code**
- How to structure Terraform modules (4 custom modules)
- Module inputs, outputs, and dependencies
- Resource lifecycle management
- Conditional resource creation (Secrets Manager example)

✅ **AWS EKS Architecture**
- VPC design for Kubernetes (public/private subnets)
- Control plane vs data plane separation
- Node groups and scaling strategies
- EKS networking (VPC CNI, CoreDNS, kube-proxy)

✅ **Kubernetes Fundamentals**
- How pods, services, and deployments work
- Kubernetes networking (CNI, kube-proxy, CoreDNS)
- Service types (ClusterIP, NodePort, LoadBalancer)
- How EKS integrates with AWS services

✅ **AWS Security**
- IAM roles and policies (least privilege)
- Security groups and network isolation
- KMS encryption (Kubernetes secrets in etcd)
- IRSA (pod-level IAM permissions via OIDC)

✅ **Production Best Practices**
- Multi-AZ high availability (3 AZs)
- Private subnets for workloads (nodes not exposed)
- Centralized logging (CloudWatch)
- Encryption at rest (KMS) and in transit
- Cost optimization (single NAT, spot instances)
- Optional components (Secrets Manager demo)

✅ **Module Design Patterns**
- When to create reusable modules
- How to make modules optional (conditional creation)
- Difference between demo/learning modules vs production-ready modules
- How to document optional components clearly

---

## 📚 Additional Resources

### Official Documentation
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Terraform Modules Source Code
- `modules/vpc/` - VPC, subnets, NAT, IGW
- `modules/iam/` - IAM roles, policies, OIDC
- `modules/eks/` - EKS cluster, node groups, add-ons
- `modules/secrets-manager/` - KMS, secrets, IAM policies

### Architecture Files
- `README.md` - Quick start guide
- `CUSTOM_MODULES.md` - Module documentation
- `architecture.md` - Architecture diagrams
- `DEMO_GUIDE.md` - This comprehensive guide

---

## 🔧 Troubleshooting

### Common Issues

**Issue: `terraform apply` fails with "InvalidPermissions"`**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Ensure you have required permissions (AdministratorAccess or EKS permissions)
```

**Issue: Nodes not joining cluster**
```bash
# Check node IAM role has correct policies
aws iam list-attached-role-policies --role-name day20-eks-node-xxx

# Check security group rules
kubectl describe node <node-name>
```

**Issue: Cannot connect with kubectl**
```bash
# Update kubeconfig
aws eks update-kubeconfig --name day20-eks --region us-east-1

# Test authentication
kubectl auth can-i get pods
```

**Issue: Pods can't pull images**
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways

# Check route table has route to NAT
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-xxx"

# Check node security group allows outbound traffic
```

---

## 🎉 Conclusion

Congratulations! You've successfully:

✅ Built a **production-ready EKS cluster** from scratch (44 resources)
✅ Created **4 custom Terraform modules** (VPC, IAM, EKS, Secrets Manager)
✅ Implemented **AWS security best practices** (encryption, IRSA, private subnets)
✅ Gained **deep understanding** of how EKS works under the hood
✅ Learned to **troubleshoot and verify** infrastructure
✅ Understood **module design patterns** (conditional resources, optional components)

### Key Takeaways:

**1. Custom Modules vs Public Modules**
- You now have full control over every resource
- You understand exactly what gets created and why
- You can customize for your specific needs

**2. Infrastructure Components**
- **VPC Module:** Networking foundation (18 resources)
- **IAM Module:** Permissions and roles (8 resources)
- **EKS Module:** Kubernetes cluster (18 resources)
- **Secrets Manager Module:** Optional demo (0 resources)

**3. Real-World Patterns**
- Not all modules need to be deployed
- Conditional resource creation for flexibility
- Clear documentation of what's active vs optional

**4. Production Readiness**
- Multi-AZ for high availability
- KMS encryption for security
- CloudWatch for monitoring
- Cost-optimized (single NAT, spot instances)

This knowledge is directly applicable to real-world production environments!

### What's NOT Included (But Module Shows How):
- ❌ AWS Secrets Manager (demo module, disabled)
- ❌ Database (no RDS/Aurora deployed)
- ❌ External secrets (would need database first)

**Note:** The Secrets Manager module demonstrates best practices for future use when you add databases or external APIs to your infrastructure.

---

**Project:** EKS Custom Modules Demo  
**Version:** 1.0  
**Last Updated:** November 28, 2025  
**Terraform Version:** >= 1.3  
**Kubernetes Version:** 1.31
