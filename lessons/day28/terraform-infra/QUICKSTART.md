# Quick Start Guide - Goal Tracker Infrastructure

## 🚀 5-Minute Setup

### Prerequisites Checklist
- [ ] AWS Account with admin access
- [ ] Terraform >= 1.5 installed
- [ ] AWS CLI v2 configured (`aws configure`)
- [ ] Docker installed
- [ ] SSH key pair created in AWS EC2

### Step 1: Configure (2 minutes)

```bash
cd terraform-infra/environments/dev
cp terraform.tfvars.example terraform.tfvars

# Edit these values:
# - ssh_key_name: "your-key-name"
# - allowed_ssh_cidr: "YOUR_IP/32"
```

### Step 2: Deploy Infrastructure (10-15 minutes)

```bash
# Initialize
terraform init

# Plan and apply
terraform plan -out=tfplan
terraform apply tfplan

# Save outputs
terraform output > deployment-info.txt
```

### Step 3: Build & Deploy Application (5-10 minutes)

```bash
# Run automated script
../../scripts/build-and-push.sh

# Or manually:
# 1. Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $(terraform output -raw frontend_ecr_repository_url | cut -d'/' -f1)

# 2. Build and push
cd ../../../frontend
docker build -t $(terraform output -raw frontend_ecr_repository_url):latest .
docker push $(terraform output -raw frontend_ecr_repository_url):latest

cd ../backend
docker build -t $(terraform output -raw backend_ecr_repository_url):latest .
docker push $(terraform output -raw backend_ecr_repository_url):latest

# 3. Trigger refresh
cd ../terraform-infra/environments/dev
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name)
```

### Step 4: Access Application (5 minutes)

```bash
# Get URL
terraform output application_url

# Wait for instances to be healthy
watch -n 5 'aws elbv2 describe-target-health --target-group-arn $(terraform output -raw frontend_target_group_arn)'
```

Visit the URL in your browser!

---

## 📋 Common Commands

### View Infrastructure

```bash
# Show all outputs
terraform output

# Show specific output
terraform output alb_dns_name

# List all EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=goal-tracker" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

### SSH Access

```bash
# SSH to bastion
ssh -i your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)

# From bastion to frontend instance
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*frontend*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text

ssh ec2-user@<private-ip>

# Check Docker container
docker ps
docker logs -f goal-tracker-frontend
```

### View Logs

```bash
# Frontend logs
aws logs tail /aws/ec2/dev-goal-tracker/frontend --follow

# Backend logs
aws logs tail /aws/ec2/dev-goal-tracker/backend --follow

# Filter for errors
aws logs tail /aws/ec2/dev-goal-tracker/backend --filter-pattern "ERROR"
```

### Database Access

```bash
# Get credentials
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw db_secret_name) \
  --query SecretString --output text | jq .

# Connect from bastion (install postgresql client first)
sudo yum install -y postgresql15
psql -h <db-endpoint> -U postgres -d goalsdb
```

### Update Application

```bash
# 1. Build new version
cd frontend
docker build -t $(terraform output -raw frontend_ecr_repository_url):v1.1.0 .

# 2. Push with version tag and latest
docker push $(terraform output -raw frontend_ecr_repository_url):v1.1.0
docker tag $(terraform output -raw frontend_ecr_repository_url):v1.1.0 \
           $(terraform output -raw frontend_ecr_repository_url):latest
docker push $(terraform output -raw frontend_ecr_repository_url):latest

# 3. Trigger rolling update
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name) \
  --preferences '{"MinHealthyPercentage": 90}'

# 4. Monitor refresh
aws autoscaling describe-instance-refreshes \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name)
```

### Scale Application

```bash
# Scale frontend manually
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name) \
  --desired-capacity 4

# Scale backend
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $(terraform output -raw backend_asg_name) \
  --desired-capacity 3
```

### Monitoring

```bash
# CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=$(terraform output -raw frontend_asg_name) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# ALB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --dimensions Name=LoadBalancer,Value=$(terraform output -raw alb_arn | sed 's/.*loadbalancer\///') \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

---

## 🔧 Troubleshooting

### Problem: Instances not starting

```bash
# Check ASG activity
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name) \
  --max-records 5

# Check instance system logs
INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $(terraform output -raw frontend_asg_name) \
  --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)

aws ec2 get-console-output --instance-id $INSTANCE_ID --output text
```

### Problem: Health checks failing

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw frontend_target_group_arn)

# SSH to instance and check
ssh -i your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)
# Then from bastion:
ssh ec2-user@<private-ip>
docker logs goal-tracker-frontend
curl http://localhost:3000
```

### Problem: Database connection issues

```bash
# Test from backend instance
curl -s http://localhost:8080/goals

# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier $(terraform output -raw db_name)

# Verify security groups
aws ec2 describe-security-groups \
  --filters "Name=tag:Project,Values=goal-tracker"
```

### Problem: Can't pull Docker images

```bash
# Verify ECR permissions
aws ecr describe-repositories

# Check IAM role
aws iam get-role --role-name dev-goal-tracker-ec2-role

# Manual ECR login from instance
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

---

## 🧹 Cleanup

### Quick Cleanup

```bash
cd terraform-infra/environments/dev
terraform destroy -auto-approve
```

### Thorough Cleanup

```bash
# 1. Delete ECR images first (optional)
aws ecr batch-delete-image \
  --repository-name dev-goal-tracker-frontend \
  --image-ids imageTag=latest

aws ecr batch-delete-image \
  --repository-name dev-goal-tracker-backend \
  --image-ids imageTag=latest

# 2. Destroy infrastructure
terraform destroy

# 3. Clean local state (optional)
rm -rf .terraform .terraform.lock.hcl tfplan terraform.tfstate*
```

---

## 💰 Cost Tracking

### Estimate Current Costs

```bash
# Use AWS Cost Explorer API
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '1 month ago' +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --filter file://<(cat <<EOF
{
  "Tags": {
    "Key": "Project",
    "Values": ["goal-tracker"]
  }
}
EOF
)
```

### Cost Optimization

```bash
# Stop development environment after hours (use EventBridge)
# Scale to 0 (not recommended, use stop/start instead)
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name $(terraform output -raw frontend_asg_name) \
  --min-size 0 --max-size 0 --desired-capacity 0
```

---

## 📊 Monitoring Dashboard

Access AWS Console → CloudWatch → Dashboards → Create Dashboard

Add widgets for:
- ALB Request Count
- Frontend/Backend CPU Utilization
- RDS CPU & Connections
- ASG Instance Count
- Error Rates (4xx, 5xx)

---

## 🔐 Security Checklist

- [ ] Change `allowed_ssh_cidr` from 0.0.0.0/0 to your IP
- [ ] Enable MFA on AWS account
- [ ] Rotate database password regularly
- [ ] Enable AWS GuardDuty
- [ ] Review IAM permissions
- [ ] Enable VPC Flow Logs
- [ ] Configure AWS Config rules
- [ ] Set up CloudTrail logging

---

## 📚 Additional Resources

- [Main README](README.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Module Documentation](modules/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Need help?** Check the [Troubleshooting](#troubleshooting) section or create an issue on GitHub.
