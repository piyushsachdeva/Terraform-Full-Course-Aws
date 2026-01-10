# Goal Tracker - 3-Tier AWS Infrastructure

Highly available 3-tier application: Node.js frontend, Go backend, PostgreSQL database.

## Quick Deployment

### 1. Build and Push Docker Images

```bash
# Login to Docker Hub
docker login

# Build and push frontend
cd frontend
docker build -t YOUR_USERNAME/goal-tracker-frontend:latest .
docker push YOUR_USERNAME/goal-tracker-frontend:latest

# Build and push backend
cd ../backend
docker build -t YOUR_USERNAME/goal-tracker-backend:latest .
docker push YOUR_USERNAME/goal-tracker-backend:latest
```

### 2. Configure Terraform

```bash
cd terraform-infra/environments/dev
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Required Configuration:**
```hcl
region      = "us-east-1"
environment = "dev"
project     = "goal-tracker"

ssh_key_name     = "YOUR_KEY_NAME"
allowed_ssh_cidr = "YOUR_IP/32"

frontend_docker_image = "YOUR_USERNAME/goal-tracker-frontend:latest"
backend_docker_image  = "YOUR_USERNAME/goal-tracker-backend:latest"
dockerhub_username    = "YOUR_USERNAME"
dockerhub_password    = "YOUR_DOCKER_TOKEN"

# High Availability (optional)
single_nat_gateway = false  # true = cost optimized, false = HA
db_multi_az        = true   # true = HA, false = cost optimized
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Deployment Time:** ~15-20 minutes

### 4. Access Application

```bash
# Get application URL
terraform output application_url

# Get bastion IP for SSH access
terraform output bastion_public_ip
```

## Architecture

**Deployed Resources:**
- VPC with 8 subnets across 2 AZs (public, frontend, backend, database)
- Public ALB for internet traffic
- Internal ALB for backend communication
- Auto Scaling Groups (Frontend: 2-4, Backend: 2-6 instances)
- RDS PostgreSQL (Multi-AZ optional)
- NAT Gateway (1 or 2 for HA)
- Bastion host for SSH access
- Secrets Manager for credentials
- CloudWatch for logging

## Update Application

```bash
# Rebuild and push images
docker build -t YOUR_USERNAME/goal-tracker-frontend:latest ./frontend
docker push YOUR_USERNAME/goal-tracker-frontend:latest

# Trigger instance refresh
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name dev-goal-tracker-frontend-asg \
  --region us-east-1
```

## Troubleshooting

**Check logs:**
```bash
aws logs tail /aws/ec2/dev-goal-tracker/frontend --follow --region us-east-1
```

**SSH to instances via bastion:**
```bash
ssh -i your-key.pem ec2-user@BASTION_IP
ssh ec2-user@PRIVATE_INSTANCE_IP
```

**View container status:**
```bash
docker ps -a
docker logs goal-tracker-frontend
```

## Cleanup

```bash
terraform destroy -auto-approve
```

## Local Development

```bash
cd docker-local-deployment
docker-compose up -d
```

Access at: http://localhost:3000

---

**Stack:** Terraform | Docker | AWS | Node.js | Go | PostgreSQL
