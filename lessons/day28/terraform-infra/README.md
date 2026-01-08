# Goal Tracker - 3-Tier AWS Infrastructure

Production-grade infrastructure for deploying the Goal Tracker application on AWS using Terraform, Docker, and EC2.

## 🏗️ Architecture

```
Internet → ALB (Public) → Frontend ASG (Private) → Backend ASG (Private) → RDS PostgreSQL (Isolated)
                ↓
           Bastion Host (Public, SSH access)
```

### Architecture Components

- **Web Tier (Public Subnets)**: Application Load Balancer, Bastion Host, NAT Gateways
- **Frontend Tier (Private Subnets)**: Node.js application servers with Docker
- **Backend Tier (Private Subnets)**: Go API servers with Docker
- **Data Tier (Isolated Subnets)**: PostgreSQL 15 RDS (Multi-AZ capable)

## 📁 Project Structure

```
terraform-infra/
├── modules/              # Reusable Terraform modules
│   ├── vpc/             # VPC with 3-tier subnet architecture
│   ├── security-groups/ # Security groups for all tiers
│   ├── iam/             # IAM roles for EC2 instances
│   ├── bastion/         # Bastion host for SSH access
│   ├── alb/             # Application Load Balancer
│   ├── ecr/             # ECR repositories for container images
│   ├── rds/             # PostgreSQL RDS database
│   ├── secrets/         # Secrets Manager for credentials
│   ├── frontend-asg/    # Frontend Auto Scaling Group
│   └── backend-asg/     # Backend Auto Scaling Group
│
└── environments/
    └── dev/             # Development environment
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── providers.tf
        └── terraform.tfvars.example
```

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.5 installed
3. **AWS CLI** v2 configured
4. **Docker** installed locally
5. **SSH Key Pair** created in AWS

## 🚀 Quick Start

### Step 1: Prepare Your Environment

```bash
# Clone the repository
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day28

# Navigate to dev environment
cd terraform-infra/environments/dev

# Create your terraform.tfvars from the example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vim terraform.tfvars
```

**Required Changes in `terraform.tfvars`:**
- `ssh_key_name`: Your AWS key pair name
- `allowed_ssh_cidr`: Your IP address (e.g., "203.0.113.0/32")

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -out=tfplan

# Apply the infrastructure
terraform apply tfplan
```

**Deployment time**: ~10-15 minutes

### Step 3: Build and Push Docker Images

```bash
# Get ECR repository URLs from outputs
FRONTEND_REPO=$(terraform output -raw frontend_ecr_repository_url)
BACKEND_REPO=$(terraform output -raw backend_ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $(echo $FRONTEND_REPO | cut -d'/' -f1)

# Build and push frontend
cd ../../../frontend
docker build -t $FRONTEND_REPO:latest .
docker push $FRONTEND_REPO:latest

# Build and push backend
cd ../backend
docker build -t $BACKEND_REPO:latest .
docker push $BACKEND_REPO:latest
```

### Step 4: Trigger Instance Refresh

After pushing images, refresh ASG instances to pull the new containers:

```bash
cd ../terraform-infra/environments/dev

# Get ASG names
FRONTEND_ASG=$(terraform output -raw frontend_asg_name)
BACKEND_ASG=$(terraform output -raw backend_asg_name)

# Trigger rolling update
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $FRONTEND_ASG \
  --preferences '{"MinHealthyPercentage": 90}' \
  --region us-east-1

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $BACKEND_ASG \
  --preferences '{"MinHealthyPercentage": 90}' \
  --region us-east-1
```

### Step 5: Access Your Application

```bash
# Get the Application URL
terraform output application_url

# Example: http://dev-goal-tracker-alb-123456789.us-east-1.elb.amazonaws.com
```

Visit the URL in your browser to access the Goal Tracker application!

## 🔐 Security Features

- ✅ **Network Isolation**: 3-tier architecture with complete separation
- ✅ **Security Groups**: Least privilege access using security group chaining
- ✅ **Encrypted Storage**: EBS and RDS encryption enabled
- ✅ **Secrets Management**: Database credentials in AWS Secrets Manager
- ✅ **No Public Database**: RDS in completely isolated subnets
- ✅ **Bastion Access**: Secure SSH access point (optional: use Session Manager)
- ✅ **IMDSv2**: Instance metadata service v2 required

## 📊 Monitoring & Logging

### CloudWatch Logs

```bash
# View frontend logs
aws logs tail /aws/ec2/dev-goal-tracker/frontend --follow

# View backend logs
aws logs tail /aws/ec2/dev-goal-tracker/backend --follow
```

### CloudWatch Metrics

- Custom metrics for CPU and memory usage
- Auto Scaling Group metrics
- RDS performance metrics
- ALB request metrics

### Alarms

- High CPU utilization (>80%)
- Unhealthy target instances
- Database connection issues

## 🔄 Updates & Maintenance

### Updating Application Code

```bash
# 1. Build new image with a tag
docker build -t $BACKEND_REPO:v1.2.0 .

# 2. Push tagged version
docker push $BACKEND_REPO:v1.2.0

# 3. Update latest tag
docker tag $BACKEND_REPO:v1.2.0 $BACKEND_REPO:latest
docker push $BACKEND_REPO:latest

# 4. Trigger ASG refresh (see Step 4 above)
```

### Scaling

```bash
# Scale frontend manually
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $FRONTEND_ASG \
  --desired-capacity 4

# Auto-scaling policies are configured for CPU-based scaling
```

## 💰 Cost Optimization

### Development Environment (~$145/month)

- Single NAT Gateway: Enabled
- t3.micro instances: 4 instances
- db.t3.micro: Single-AZ
- Minimal CloudWatch logs

### Reduce Costs Further

1. **Stop after hours**: Use Lambda to stop/start instances
2. **Use Spot Instances**: Mix of On-Demand and Spot
3. **Reduce instance count**: min_size = 1
4. **Disable NAT**: If outbound internet not needed

## 🧹 Cleanup

```bash
# Destroy all infrastructure
terraform destroy

# Manually delete ECR images if needed
aws ecr batch-delete-image \
  --repository-name dev-goal-tracker-frontend \
  --image-ids imageTag=latest

aws ecr batch-delete-image \
  --repository-name dev-goal-tracker-backend \
  --image-ids imageTag=latest
```

## 🔧 Troubleshooting

### Instances not starting

```bash
# Check ASG activity
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name $FRONTEND_ASG \
  --max-records 10

# SSH to bastion and then to private instance
ssh -i your-key.pem ec2-user@<bastion-ip>
ssh ec2-user@<private-ip>

# Check Docker logs
docker logs goal-tracker-frontend
docker logs goal-tracker-backend
```

### Database connection issues

```bash
# Test from backend instance
curl -s http://localhost:8080/goals

# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier dev-goal-tracker-postgres

# Verify secrets
aws secretsmanager get-secret-value \
  --secret-id dev-goal-tracker-db-credentials
```

### ALB health checks failing

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Common issues:
# - Security group blocking port 3000
# - Container not running
# - Application not listening on correct port
```

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 🤝 Contributing

This is a learning project from the "30 Days of AWS with Terraform" course. Feel free to suggest improvements!

## 📄 License

MIT License - See LICENSE file for details

---

**Built with ❤️ for the 30 Days of AWS with Terraform challenge**
