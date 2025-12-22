# 🚀 Terraform Multi-Environment CI/CD Demo Guide

A comprehensive demonstration of a **production-grade Infrastructure as Code (IaC)** pipeline using Terraform, GitHub Actions, and AWS.

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Prerequisites & Setup](#prerequisites--setup)
3. [Core Features](#core-features)
4. [Demo Scenarios](#demo-scenarios)
5. [Advanced Features](#advanced-features)
6. [Troubleshooting & Best Practices](#troubleshooting--best-practices)

---

## 🏗️ Architecture Overview

### Infrastructure Components
This project deploys a **highly available, secure, and scalable** 2-tier web application architecture:

**Network Layer:**
- **VPC** with DNS support and hostnames enabled
- **Public Subnets** (2 AZs) for Load Balancers with auto-assigned public IPs
- **Private Subnets** (2 AZs) for application instances (no direct internet access)
- **Internet Gateway** for public subnet internet connectivity
- **NAT Gateway** for private subnet outbound access (updates, etc.)
- **Route Tables** with appropriate routing for public/private traffic

**Compute Layer:**
- **Application Load Balancer (ALB)** distributing traffic across AZs
- **Auto Scaling Group** with dynamic scaling policies
- **Launch Template** with user data for automated instance configuration
- **EC2 Instances** running Nginx web server
- **Target Group** with health checks

**Security:**
- **Security Groups** with least-privilege access:
  - ALB SG: HTTP/HTTPS from internet
  - App SG: HTTP/HTTPS only from ALB
  - SSH SG: Optional SSH access (should be restricted in production)
- **IMDSv2** enforced for enhanced instance metadata security
- **Private subnets** for application tier

**Storage:**
- **S3 Bucket** with versioning, encryption, and public access blocked
- **Terraform State** stored in S3 with native locking

**Monitoring:**
- **CloudWatch Alarms** for CPU utilization
- **Auto Scaling Policies** (Target Tracking, Simple Scaling In/Out)
- **ALB Health Checks** with automatic instance replacement

### Multi-Environment Strategy

We manage **three isolated environments** using Terraform workspaces:

| Environment | Branch | VPC CIDR      | Deployment      | Approval Required |
|-------------|--------|---------------|-----------------|-------------------|
| **Dev**     | `dev`  | 10.0.0.0/16   | Auto on push    | No                |
| **Test**    | `test` | 10.1.0.0/16   | Auto on push    | No                |
| **Prod**    | `main` | 10.2.0.0/16   | Manual approval | **Yes**           |

**Terraform Workspace Isolation:**
- Each environment uses a separate workspace: `dev`, `test`, `prod`
- State files are isolated in S3: `s3://bucket/env:/{workspace}/terraform/state/main/terraform.tfstate`
- Resources are suffixed with environment names to avoid naming collisions

---

## 🔧 Prerequisites & Setup

### 1. AWS Account Preparation

**Create S3 Backend (One-time):**
```bash
# Create bucket for Terraform state
aws s3 mb s3://staging-my-terraform-bucket-saydhw --region us-east-1

# Enable versioning for state history
aws s3api put-bucket-versioning \
  --bucket staging-my-terraform-bucket-saydhw \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket staging-my-terraform-bucket-saydhw \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

**Update `backend.tf`** with your bucket name:
```hcl
terraform {
  backend "s3" {
    bucket       = "staging-my-terraform-bucket-saydhw"  # Your bucket name
    key          = "terraform/state/main/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true  # S3 Native Locking (Terraform 1.13+)
    encrypt      = true
  }
}
```

### 2. GitHub Repository Configuration

**A. Add AWS Credentials (Repository Secrets):**
1. Navigate to: `Settings` → `Secrets and variables` → `Actions`
2. Click **"New repository secret"**
3. Add:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

> ⚠️ **Important:** Use **Repository secrets**, not Environment secrets, for AWS credentials.

**B. Configure Environment Protection:**
1. Navigate to: `Settings` → `Environments`
2. Create **`prod`** environment:
   - Click **"New environment"** → Enter `prod`
   - Enable **"Required reviewers"**
   - Add yourself (and team members) as reviewers
   - Save protection rules
3. *(Optional)* Create `dev` and `test` environments for deployment tracking

### 3. Local Development Setup

```bash
# Install Terraform (version 1.13+)
terraform version

# Install TFLint (optional, for local validation)
tflint --version

# Clone repository
git clone https://github.com/itsBaivab/aws-devops.git
cd aws-devops

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

---

## 🎯 Core Features

### 1. Multi-Environment Deployment
- **Workspace-based isolation** prevents environment cross-contamination
- **Environment-specific variables** via `.tfvars` files
- **Resource naming convention** includes environment suffix
- **Separate state files** for complete independence

### 2. CI/CD Pipeline

**On Pull Request (Plan Phase):**
```mermaid
PR Created → TFLint → Trivy Scan → Terraform Init → Format Check → 
Validate → Plan → Comment on PR
```

**On Merge/Push (Apply Phase):**
```mermaid
Code Merged → Init → Set Workspace → Plan → [Approval for Prod] → Apply → 
Infrastructure Updated
```

**Workflow Features:**
- ✅ **Automated security scanning** (TFLint + Trivy)
- ✅ **Code formatting checks** (terraform fmt)
- ✅ **Validation** before deployment
- ✅ **Plan artifacts** uploaded/downloaded for consistency
- ✅ **PR comments** with detailed plan output
- ✅ **Environment-based approvals** for production safety

### 3. Security Hardening

**Infrastructure Security:**
- Private subnets for application tier
- Security groups with minimal required access
- IMDSv2 enforcement on EC2 instances
- S3 bucket with encryption and blocked public access
- NAT Gateway for controlled egress

**Pipeline Security:**
- TFLint detects unused variables and potential issues
- Trivy scans for critical/high vulnerabilities in IaC
- Secrets managed through GitHub Actions
- Production requires manual approval

### 4. Auto Scaling & High Availability

**Scaling Policies:**
- **Target Tracking:** Maintains 50% CPU utilization
- **Simple Scale Out:** Add 1 instance when CPU > 70%
- **Simple Scale In:** Remove 1 instance when CPU < 30%
- **Health Check Grace Period:** 300 seconds
- **ELB Health Checks:** Replace unhealthy instances

**High Availability:**
- Multi-AZ deployment (us-east-1a, us-east-1b)
- Application Load Balancer distributes traffic
- Auto Scaling ensures desired capacity

### 5. Infrastructure Destruction

**Manual Workflow (`terraform-destroy.yml`):**
- Workflow dispatch trigger (manual execution only)
- Environment selection dropdown
- Confirmation required: Type "DESTROY" to proceed
- Protected by GitHub environment approvals

---

## 🎬 Demo Scenarios

### Demo 1: Feature Development & Deployment to Dev

**Scenario:** Scale up the development environment to handle increased load.

**Steps:**
```bash
# 1. Create feature branch
git checkout -b feat/scale-up-dev

# 2. Edit dev.tfvars
# Change: desired_capacity = 1 → desired_capacity = 2
vim dev.tfvars

# 3. Commit and push
git add dev.tfvars
git commit -m "feat: scale up dev environment capacity"
git push origin feat/scale-up-dev
```

**4. Create Pull Request:**
- Go to GitHub → Open PR from `feat/scale-up-dev` to `dev`
- Watch automated checks run:
  - ✅ TFLint checks for code quality
  - ✅ Trivy scans for security issues
  - ✅ Terraform plan shows proposed changes
- Review the plan comment on PR:
  ```
  Plan: 1 to add, 0 to change, 0 to destroy
  ```

**5. Merge PR:**
- Click "Merge pull request"
- Navigate to Actions tab
- Watch the deployment:
  - Terraform Plan (creates artifact)
  - Terraform Apply (uses artifact, runs automatically)

**6. Verify in AWS:**
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names app-asg-dev

# Check running instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=app-instance-dev" \
  --query 'Reservations[].Instances[].InstanceId'
```

**Expected Result:** Development environment now has 2 running instances.

---

### Demo 2: Security Scanning in Action

**Scenario:** Demonstrate how the pipeline catches security issues before deployment.

**Steps:**
```bash
# 1. Create a branch with an intentional issue
git checkout -b security-test

# 2. Introduce a security issue in security_groups.tf
# Example: Open SSH to the world (if not already)
# Change CIDR from your IP to 0.0.0.0/0

vim security_groups.tf
# In allow_ssh security group:
# cidr_blocks = ["0.0.0.0/0"]  # INTENTIONALLY INSECURE

# 3. Push and create PR
git add security_groups.tf
git commit -m "test: security scan demo"
git push origin security-test
```

**4. Review Pipeline Results:**
- Navigate to Actions tab → Click on the workflow run
- Observe Trivy findings:
  ```
  AVD-AWS-0107 (HIGH): Security group rule allows unrestricted SSH access
  ```
- TFLint may also flag issues

**Key Talking Points:**
- "The pipeline automatically catches this critical security issue"
- "Trivy provides detailed remediation guidance"
- "We can fix this before it ever reaches production"

**Cleanup:**
```bash
# Don't merge this PR - close it
# Delete the branch
git checkout dev
git branch -D security-test
git push origin --delete security-test
```

---

### Demo 3: Production Deployment with Approval Gate

**Scenario:** Promote changes from dev to production with manual approval.

**Steps:**
```bash
# 1. Ensure dev branch has the changes you want
git checkout dev
git pull origin dev

# 2. Create PR to main
git checkout -b promote-to-prod
# No changes needed if just promoting dev
git push origin promote-to-prod
```

**3. Create Pull Request:**
- Go to GitHub → Open PR from `promote-to-prod` to `main`
- Review the Terraform plan in PR comments
- Note the environment: `Environment 🌍 prod`

**4. Merge PR:**
- Click "Merge pull request"
- Navigate to Actions tab → Click on the running workflow

**5. The Approval Gate:**
- Pipeline reaches "Terraform Apply" and **pauses**
- Yellow indicator shows "Waiting for approval"
- Click **"Review deployments"**
- Select `prod` environment
- Click **"Approve and deploy"**

**6. Watch Deployment:**
- Terraform applies changes to production
- View detailed logs in real-time

**7. Verify Production:**
```bash
# Check production resources
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=main-vpc-production"

# Get ALB DNS
aws elbv2 describe-load-balancers \
  --names app-load-balancer-production \
  --query 'LoadBalancers[0].DNSName' --output text

# Test the endpoint
curl http://<ALB-DNS>
```

**Key Talking Points:**
- "Production requires explicit human approval"
- "The exact same plan artifact from the plan phase is applied"
- "No surprises - we know exactly what's being deployed"
- "Approval history is tracked in GitHub"

---

### Demo 4: Multi-Environment Comparison

**Scenario:** Show how three environments coexist with complete isolation.

**Steps:**
```bash
# 1. Show workspace separation
terraform workspace list

# 2. Check dev state
terraform workspace select dev
terraform show | head -20

# 3. Check prod state
terraform workspace select prod
terraform show | head -20

# 4. Show S3 state structure
aws s3 ls s3://staging-my-terraform-bucket-saydhw/env:/ --recursive
```

**Expected Output:**
```
env:/dev/terraform/state/main/terraform.tfstate
env:/prod/terraform/state/main/terraform.tfstate
env:/test/terraform/state/main/terraform.tfstate
```

**5. Compare Resources in AWS Console:**
- Show three separate VPCs (10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16)
- Show three separate ALBs with environment suffixes
- Show three separate Auto Scaling Groups

**Key Talking Points:**
- "Each environment is completely isolated"
- "State files never interfere with each other"
- "Resources are clearly labeled by environment"
- "Same code, different configurations"

---

### Demo 5: Infrastructure Destruction

**Scenario:** Safely tear down the test environment.

**Steps:**
1. Navigate to GitHub → Actions tab
2. Select "Terraform Destroy" workflow
3. Click **"Run workflow"** button
4. Configure:
   - **Branch:** Select `main` (or where the workflow exists)
   - **Environment:** Select `test`
   - **Confirmation:** Type `DESTROY`
5. Click **"Run workflow"**

**6. Monitor Destruction:**
- Click on the running workflow
- Watch as Terraform systematically destroys resources:
  - Auto Scaling Group → Launch Template
  - Load Balancer → Target Group
  - NAT Gateway → EIP
  - Subnets → VPC
  - S3 Bucket → Objects

**7. Verify Cleanup:**
```bash
# Switch to test workspace
terraform workspace select test
terraform show

# Should show: No resources in state
```

**Key Talking Points:**
- "Manual workflow prevents accidental destruction"
- "Confirmation requirement adds extra safety"
- "Terraform destroys in correct dependency order"
- "Can rebuild identical environment from code anytime"

---

### Demo 6: Format Check & Code Quality

**Scenario:** Show how the pipeline enforces code standards.

**Steps:**
```bash
# 1. Create a branch with improper formatting
git checkout -b format-test

# 2. Edit a file with bad formatting
cat >> variables.tf << 'EOF'

variable   "demo_var"  {
  description="Badly formatted"
type=string
    default   =   "test"
}
EOF

# 3. Push without formatting
git add variables.tf
git commit -m "test: unformatted code"
git push origin format-test
```

**4. Create PR and observe failure:**
- Pipeline fails at "Terraform Format" step
- Shows which files need formatting:
  ```
  variables.tf
  Error: Terraform exited with code 3
  ```

**5. Fix formatting:**
```bash
# Format code locally
terraform fmt

# Commit fix
git add variables.tf
git commit -m "fix: format code"
git push origin format-test
```

**6. Pipeline passes:**
- All checks now green ✅
- PR can be merged

**Cleanup:**
```bash
# Remove the test variable
git checkout dev
git branch -D format-test
git push origin --delete format-test
```

---

## 🚀 Advanced Features

### 1. Workspace Management

**Commands:**
```bash
# List all workspaces
terraform workspace list

# Create new workspace
terraform workspace new staging

# Switch workspace
terraform workspace select prod

# Show current workspace
terraform workspace show

# Delete workspace (must be empty)
terraform workspace delete staging
```

### 2. State Management

**View State:**
```bash
# Show all resources in current workspace
terraform state list

# Show specific resource details
terraform state show aws_vpc.main

# Pull remote state locally
terraform state pull > state.json
```

**State Operations:**
```bash
# Move resource to different name
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state (doesn't destroy)
terraform state rm aws_instance.test

# Import existing AWS resource
terraform import aws_vpc.main vpc-12345678
```

### 3. Targeted Operations

**Apply specific resources:**
```bash
# Only create/update VPC
terraform apply -target=aws_vpc.main -var-file=dev.tfvars

# Multiple targets
terraform apply \
  -target=aws_vpc.main \
  -target=aws_subnet.public \
  -var-file=dev.tfvars

# Destroy specific resource
terraform destroy -target=aws_nat_gateway.main -var-file=dev.tfvars
```

### 4. Debugging & Logging

**Enable detailed logging:**
```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log

# Run operation
terraform apply -var-file=dev.tfvars

# View logs
cat terraform.log
```

**Common log levels:**
- `TRACE` - Most verbose
- `DEBUG` - Detailed information
- `INFO` - General information
- `WARN` - Warning messages
- `ERROR` - Error messages only

### 5. Drift Detection

**Detect configuration drift:**
```bash
# Compare actual infrastructure to desired state
terraform plan -var-file=prod.tfvars -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Successful plan with changes (drift detected)
```

**Scheduled drift detection (add to workflow):**
```yaml
name: Drift Detection
on:
  schedule:
    - cron: '0 8 * * 1-5'  # Weekdays at 8 AM
  workflow_dispatch:

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Plan
        run: terraform plan -var-file=prod.tfvars -detailed-exitcode
```

### 6. Cost Estimation (External Tool)

**Using Infracost:**
```bash
# Install infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Get cost breakdown
infracost breakdown --path . --terraform-var-file dev.tfvars

# Compare cost difference
infracost diff --path . --terraform-var-file prod.tfvars
```

---

## 🔍 Troubleshooting & Best Practices

### Common Issues

**1. State Lock Conflicts**
```
Error: Error acquiring the state lock
```
**Solution:**
```bash
# Check S3 for lock file
aws s3 ls s3://your-bucket/env:/dev/terraform/state/main/

# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

**2. Workspace Not Found**
```
Error: Workspace "dev" doesn't exist
```
**Solution:**
```bash
# Create workspace before selecting
terraform workspace new dev
```

**3. Provider Plugin Issues**
```
Error: Failed to query available provider packages
```
**Solution:**
```bash
# Clear Terraform cache
rm -rf .terraform/
rm .terraform.lock.hcl

# Re-initialize
terraform init -upgrade
```

**4. Resource Already Exists**
```
Error: Resource already exists
```
**Solution:**
```bash
# Import existing resource into state
terraform import <resource_type>.<resource_name> <resource_id>

# Example:
terraform import aws_lb_target_group.app_tg arn:aws:elasticloadbalancing:...
```

**5. Invalid CIDR Block**
```
Error: InvalidSubnet.Range: The CIDR is invalid
```
**Solution:**
- Ensure subnet CIDRs fall within VPC CIDR range
- Check for CIDR conflicts between subnets
- Update `.tfvars` files with correct CIDRs

### Best Practices

**1. State Management**
- ✅ Always use remote state (S3) for team collaboration
- ✅ Enable state locking to prevent concurrent modifications
- ✅ Use separate state files per environment (workspaces)
- ✅ Enable versioning on S3 bucket for state history
- ✅ Never commit `.tfstate` files to version control
- ✅ Regularly backup state files

**2. Code Organization**
- ✅ Use meaningful resource names with environment suffix
- ✅ Organize code into logical files (vpc.tf, alb.tf, etc.)
- ✅ Use variables for all environment-specific values
- ✅ Document complex logic with comments
- ✅ Keep `.tfvars` files for each environment
- ✅ Use `locals` for computed values

**3. Security**
- ✅ Store secrets in GitHub Secrets, never in code
- ✅ Use IMDSv2 for EC2 instances
- ✅ Enable encryption for S3 state bucket
- ✅ Implement least-privilege security groups
- ✅ Use private subnets for application tier
- ✅ Regularly run security scans (Trivy, TFLint)
- ✅ Rotate AWS credentials periodically
- ✅ Enable MFA for production deployments

**4. CI/CD Pipeline**
- ✅ Always run plan before apply
- ✅ Use plan artifacts to ensure consistency
- ✅ Require approvals for production changes
- ✅ Run linting and security scans on every PR
- ✅ Comment terraform plans on PRs for visibility
- ✅ Use separate workflows for destroy operations
- ✅ Tag releases for production deployments

**5. Terraform Code**
- ✅ Run `terraform fmt` before committing
- ✅ Use `terraform validate` to check syntax
- ✅ Pin provider versions for reproducibility
- ✅ Use `count` and `for_each` for similar resources
- ✅ Leverage `data` sources for existing resources
- ✅ Use `depends_on` only when necessary
- ✅ Add `lifecycle` rules for special handling

**6. Monitoring & Alerting**
- ✅ Enable CloudWatch monitoring for all resources
- ✅ Set up alarms for critical metrics
- ✅ Configure SNS for alert notifications
- ✅ Monitor Auto Scaling activity
- ✅ Track ALB health check failures
- ✅ Review Terraform logs after deployments

### Performance Optimization

**1. Reduce Plan/Apply Time:**
```bash
# Use parallelism (default is 10)
terraform apply -parallelism=20 -var-file=dev.tfvars

# Target specific resources for testing
terraform apply -target=aws_instance.app -var-file=dev.tfvars
```

**2. Optimize State Operations:**
```bash
# Refresh state before operations
terraform refresh -var-file=dev.tfvars

# Skip refresh when not needed
terraform apply -refresh=false -var-file=dev.tfvars
```

**3. Cache Provider Plugins:**
```bash
# Set plugin cache directory
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR
```

### Disaster Recovery

**Backup Strategy:**
```bash
# Backup current state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Restore from backup
terraform state push backup-20231215-120000.tfstate
```

**S3 Versioning Recovery:**
```bash
# List state file versions
aws s3api list-object-versions \
  --bucket staging-my-terraform-bucket-saydhw \
  --prefix env:/prod/terraform/state/main/terraform.tfstate

# Restore specific version
aws s3api get-object \
  --bucket staging-my-terraform-bucket-saydhw \
  --key env:/prod/terraform/state/main/terraform.tfstate \
  --version-id <version-id> \
  restored-state.tfstate
```

### Testing Strategies

**1. Local Testing:**
```bash
# Test in isolated workspace
terraform workspace new test-feature
terraform apply -var-file=dev.tfvars

# Validate changes
curl http://<alb-dns>

# Destroy test environment
terraform destroy -var-file=dev.tfvars
terraform workspace select dev
terraform workspace delete test-feature
```

**2. PR-Based Testing:**
- Always create PRs for changes
- Review terraform plan output in PR comments
- Test in dev environment first
- Promote to test, then prod

**3. Blue-Green Deployments:**
```bash
# Create green environment
terraform workspace new green
terraform apply -var-file=prod.tfvars

# Switch traffic (update DNS/ALB)
# ...

# Destroy blue environment
terraform workspace select blue
terraform destroy -var-file=prod.tfvars
```

---

## 📚 Additional Resources

### Documentation Links
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Useful Commands Reference

**Terraform Basics:**
```bash
terraform init          # Initialize working directory
terraform plan          # Preview changes
terraform apply         # Apply changes
terraform destroy       # Destroy all resources
terraform validate      # Validate configuration
terraform fmt           # Format code
terraform output        # Show output values
terraform show          # Show current state
terraform graph         # Generate dependency graph
```

**Workspace Commands:**
```bash
terraform workspace list    # List workspaces
terraform workspace show    # Show current workspace
terraform workspace new     # Create workspace
terraform workspace select  # Switch workspace
terraform workspace delete  # Delete workspace
```

**State Commands:**
```bash
terraform state list                      # List resources
terraform state show <resource>           # Show resource details
terraform state mv <source> <destination> # Move resource
terraform state rm <resource>             # Remove resource
terraform state pull                      # Download state
terraform state push                      # Upload state
```

### Project Structure
```
aws-devops/
├── .github/
│   └── workflows/
│       ├── terraform.yml          # Main CI/CD pipeline
│       └── terraform-destroy.yml  # Destruction workflow
├── scripts/
│   └── user_data.sh              # EC2 initialization script
├── alb.tf                         # Load Balancer configuration
├── asg.tf                         # Auto Scaling Group
├── backend.tf                     # Terraform backend config
├── dev.tfvars                     # Development variables
├── main.tf                        # Provider configuration
├── outputs.tf                     # Output values
├── prod.tfvars                    # Production variables
├── s3.tf                          # S3 bucket configuration
├── security_groups.tf             # Security group rules
├── test.tfvars                    # Test variables
├── variables.tf                   # Variable definitions
├── vpc.tf                         # VPC and networking
├── .gitignore                     # Git ignore rules
├── .terraform.lock.hcl            # Provider lock file
├── .tflint.hcl                    # TFLint configuration
├── DEMO.md                        # This file
└── README.md                      # Project documentation
```

---

## 🎓 Key Takeaways

1. **Infrastructure as Code**: All infrastructure is version-controlled and reproducible
2. **Multi-Environment Management**: Isolated environments using Terraform workspaces
3. **Automated Testing**: TFLint and Trivy catch issues before deployment
4. **Safe Deployments**: Manual approval gates protect production
5. **State Management**: Remote state with locking prevents conflicts
6. **Security First**: Least-privilege access, encryption, and scanning
7. **High Availability**: Multi-AZ deployment with auto-scaling
8. **Observable**: CloudWatch monitoring and alarms
9. **Reversible**: Can destroy and recreate environments safely
10. **Team Collaboration**: PR-based workflow with plan visibility

---

## 🤝 Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check existing issues and documentation
- Review Terraform and AWS documentation

---

**Last Updated:** December 22, 2025
**Version:** 2.0
**Maintained by:** Infrastructure Team
