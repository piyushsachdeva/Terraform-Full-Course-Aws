# CloudOps Goal Tracker - Three-Tier Architecture

This project demonstrates a modern three-tier architecture deployed on AWS:

- **Presentation Layer (Frontend)**: Node.js/Express server serving a JavaScript frontend
- **Business Logic Layer (Backend)**: Go API service
- **Data Layer**: PostgreSQL database

## Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│     Frontend    │     │     Backend     │     │    Database     │
│    (Node.js)    │────▶│      (Go)       │────▶│   (PostgreSQL)  │
│   Port: 3000    │     │   Port: 8080    │     │    Port: 5432   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Local Development with Docker Compose

### Running the Application Locally

You can run the entire application stack using Docker Compose:

```bash
cd docker-local-deployment
docker-compose up -d
```

### Accessing Components

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Database**: localhost:5432 (use pgAdmin or any PostgreSQL client)

### Developing Components Individually

#### Frontend Development
```bash
cd frontend
npm install
npm start
```

The frontend is a Node.js/Express application that:
- Serves static files from the `/public` directory
- Provides API proxying to the backend
- Handles all user interactions

#### Backend Development
```bash
cd backend
go mod download
go run main.go
```

The backend is a Go API service that:
- Provides JSON REST API endpoints
- Connects to the PostgreSQL database
- Implements business logic
- Exposes metrics for monitoring

### API Endpoints

#### Backend API (Go Service)
- `GET /goals` - Get all goals
- `POST /goals` - Add a new goal
- `DELETE /goals/:id` - Delete a goal by ID
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics endpoint

#### Frontend API Proxy (Node.js)
- `GET /api/goals` - Proxy to backend's GET /goals
- `POST /api/goals` - Proxy to backend's POST /goals
- `DELETE /api/goals/:id` - Proxy to backend's DELETE /goals/:id

---

## 3-Tier Application Infrastructure on AWS

This Terraform project deploys a secure, highly available, and scalable 3-tier application infrastructure on AWS.

### Architecture Components

#### **Public Tier (Internet-Facing)**
- **Public Application Load Balancer (ALB)**: Routes HTTP/HTTPS traffic from internet to frontend
- **Bastion Host**: Secure SSH access to private resources
- **NAT Gateway**: Enables private instances to access internet

#### **Frontend Tier (Private)**
- **Auto Scaling Group**: 2-6 Node.js EC2 instances (t3.micro)
- **Docker Containers**: Frontend application running in containers
- **Internal ALB**: Service discovery for backend communication
- **Private Subnets**: Deployed across 2 Availability Zones

#### **Backend Tier (Private)**
- **Auto Scaling Group**: 2-6 Go API EC2 instances (t3.micro)
- **Docker Containers**: Backend application running in containers
- **Internal Load Balancer**: Routes traffic from frontend to backend
- **Private Subnets**: Deployed across 2 Availability Zones

#### **Database Tier (Isolated)**
- **RDS PostgreSQL 15**: Managed database service
- **Isolated Subnets**: No internet access, database-only tier
- **Multi-AZ Option**: High availability (optional for cost optimization)

#### **Supporting Infrastructure**
- **Docker Hub**: Container image registry
- **AWS Secrets Manager**: Secure storage for database credentials
- **Security Groups**: Network-level security with chaining
- **CloudWatch**: Monitoring and logging
- **VPC**: Isolated network with 4-tier subnet design

---

## Prerequisites

Before deploying, ensure you have:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** v1.5.0 or later
   ```bash
   terraform version
   ```
4. **Docker** installed for building and pushing images
   ```bash
   docker --version
   ```
5. **SSH Key Pair** created in AWS EC2
   ```bash
   aws ec2 create-key-pair --key-name goal-tracker-key --query 'KeyMaterial' --output text > goal-tracker-key.pem
   chmod 400 goal-tracker-key.pem
   ```

---

## Project Structure

```
terraform-infra/
├── environments/
│   └── dev/
│       ├── main.tf                 # Root configuration
│       ├── variables.tf            # Input variables
│       ├── outputs.tf              # Output values
│       └── terraform.tfvars.example # Example configuration
├── modules/
│   ├── vpc/                        # VPC, subnets, NAT, IGW
│   ├── security-groups/            # Security group rules
│   ├── iam/                        # IAM roles and policies
│   ├── bastion/                    # Jump host
│   ├── alb/                        # Application Load Balancer
│   ├── frontend-asg/               # Frontend Auto Scaling Group
│   ├── backend-asg/                # Backend Auto Scaling Group
│   ├── rds/                        # PostgreSQL database
│   └── secrets/                    # Secrets Manager
└── scripts/
    ├── frontend_user_data.sh       # Frontend EC2 bootstrap
    ├── backend_user_data.sh        # Backend EC2 bootstrap
    ├── build-and-push.sh           # Build & push Docker images
    └── deploy.sh                   # Terraform deployment wrapper
```

---

## Deployment Instructions

### Step 1: Build and Push Docker Images to Docker Hub

#### 1.1 Create Docker Hub Account
If you don't have one, sign up at [Docker Hub](https://hub.docker.com/)

#### 1.2 Login to Docker Hub
```bash
docker login
```

#### 1.3 Build Docker Images
```bash
# Build frontend image
cd frontend
docker build -t your-dockerhub-username/goal-tracker-frontend:latest .

# Build backend image
cd ../backend
docker build -t your-dockerhub-username/goal-tracker-backend:latest .
```

#### 1.4 Push Images to Docker Hub
```bash
# Push frontend
docker push your-dockerhub-username/goal-tracker-frontend:latest

# Push backend
docker push your-dockerhub-username/goal-tracker-backend:latest
```

**Note**: For private repositories, generate a Personal Access Token from Docker Hub settings instead of using your password.

### Step 2: Configure Terraform

#### 2.1 Navigate to Environment Directory
```bash
cd terraform-infra/environments/dev
```

#### 2.2 Copy Example Variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

#### 2.3 Edit terraform.tfvars
```bash
nano terraform.tfvars
```

Update the following values:
```hcl
# AWS Configuration
region      = "us-east-1"
environment = "dev"
project     = "goal-tracker"

# SSH Configuration
ssh_key_name     = "goal-tracker-key"  # Your EC2 key pair name
allowed_ssh_cidr = "YOUR_IP_ADDRESS/32"  # Your public IP

# Docker Hub Configuration
frontend_docker_image = "your-dockerhub-username/goal-tracker-frontend:latest"
backend_docker_image  = "your-dockerhub-username/goal-tracker-backend:latest"
dockerhub_username    = "your-dockerhub-username"
dockerhub_password    = "YOUR_PERSONAL_ACCESS_TOKEN"  # Use PAT, not password

# Database Configuration
db_name     = "goalsdb"
db_username = "postgres"

# Instance Configuration
frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.micro"
bastion_instance_type  = "t2.micro"

# Auto Scaling
frontend_min_size = 2
frontend_max_size = 4
backend_min_size  = 2
backend_max_size  = 6

# Cost Optimization
single_nat_gateway = true  # Use false for high availability
db_multi_az        = false # Use true for high availability
```

### Step 3: Initialize Terraform

```bash
terraform init
```

This command will:
- Download required provider plugins (AWS)
- Initialize the backend
- Prepare modules for use

### Step 4: Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the plan carefully. Terraform will show:
- Resources to be created (~50+ resources)
- Estimated costs
- Configuration details

### Step 5: Deploy Infrastructure

```bash
terraform apply tfplan
```

**Deployment time**: Approximately 15-20 minutes

The deployment will create:
- ✅ VPC with 8 subnets across 2 AZs
- ✅ NAT Gateway and Internet Gateway
- ✅ Security Groups with proper chaining
- ✅ RDS PostgreSQL database
- ✅ Secrets Manager with database credentials
- ✅ Public and Internal ALBs
- ✅ Frontend and Backend Auto Scaling Groups
- ✅ Bastion host
- ✅ IAM roles and policies
- ✅ CloudWatch log groups

### Step 6: Get Deployment Information

```bash
terraform output
```

Key outputs:
- **application_url**: Frontend URL (http://alb-dns-name)
- **bastion_public_ip**: SSH access point
- **db_endpoint**: Database endpoint (internal only)
- **helpful_commands**: Quick reference commands

---

## Accessing the Application

### Frontend Application
```bash
# Get the URL
terraform output application_url

# Open in browser
http://<public-alb-dns>
```

### SSH to Bastion Host
```bash
ssh -i your-key.pem ec2-user@$(terraform output -raw bastion_public_ip)
```

### View Application Logs
```bash
# Frontend logs
aws logs tail /aws/ec2/dev-goal-tracker/frontend --follow --region us-east-1

# Backend logs
aws logs tail /aws/ec2/dev-goal-tracker/backend --follow --region us-east-1
```

### Get Database Credentials
```bash
aws secretsmanager get-secret-value \
  --secret-id dev-goal-tracker-db-credentials \
  --region us-east-1 \
  --query SecretString \
  --output text | jq .
```

---

## Updating the Application

### Option 1: Using the Build Script

```bash
cd terraform-infra/environments/dev
../../scripts/build-and-push.sh
```

This script will:
1. Build both Docker images
2. Push to Docker Hub
3. Optionally trigger ASG instance refresh

### Option 2: Manual Update

```bash
# Build and push new images
docker build -t your-username/goal-tracker-frontend:latest ./frontend
docker push your-username/goal-tracker-frontend:latest

docker build -t your-username/goal-tracker-backend:latest ./backend
docker push your-username/goal-tracker-backend:latest

# Trigger instance refresh
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name dev-goal-tracker-frontend-asg \
  --region us-east-1

aws autoscaling start-instance-refresh \
  --auto-scaling-group-name dev-goal-tracker-backend-asg \
  --region us-east-1
```

---

## Infrastructure Management

### Scaling Configuration

Auto Scaling Groups automatically scale based on:
- **CPU Utilization**: Target 70%
- **Min Instances**: 2 (high availability)
- **Max Instances**: Frontend=4, Backend=6

### Cost Optimization

**Development Environment** (Default):
- Single NAT Gateway: ~$32/month
- Single-AZ RDS: ~$15/month
- 2x t3.micro instances: ~$12/month

**Production Environment** (Recommended):
```hcl
single_nat_gateway = false  # 2 NAT Gateways for HA
db_multi_az        = true   # Multi-AZ RDS
```

### Security Features

- ✅ **Network Isolation**: 4-tier VPC design
- ✅ **Security Group Chaining**: ALB → Frontend → Internal ALB → Backend → RDS
- ✅ **No Public Access**: Backend and database in private subnets
- ✅ **Secrets Management**: Credentials stored in AWS Secrets Manager
- ✅ **SSH Access**: Only via Bastion host
- ✅ **Encryption**: EBS volumes and RDS encrypted at rest
- ✅ **IMDSv2**: Required for EC2 metadata access

### Monitoring

Access CloudWatch dashboards for:
- ASG metrics (CPU, instance counts)
- ALB metrics (request count, latency, 5xx errors)
- RDS metrics (connections, CPU, storage)
- Custom application logs

---

## Troubleshooting

### Instances Not Healthy

```bash
# Check ASG health
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names dev-goal-tracker-frontend-asg \
  --region us-east-1

# Check instance user data logs
ssh -i your-key.pem ec2-user@<bastion-ip>
# Then SSH to private instance
ssh ec2-user@<private-instance-ip>
cat /var/log/user-data.log
```

### Docker Container Issues

```bash
# SSH to instance
docker ps -a  # Check container status
docker logs goal-tracker-frontend  # Check container logs
docker logs goal-tracker-backend
```

### Database Connection Issues

```bash
# Verify security group rules
aws ec2 describe-security-groups \
  --group-ids <backend-sg-id> \
  --region us-east-1

# Test connectivity from backend instance
nc -zv <rds-endpoint> 5432
```

---

## Cleanup

### Destroy Infrastructure

```bash
cd terraform-infra/environments/dev
terraform destroy -auto-approve
```

**Warning**: This will permanently delete:
- All EC2 instances
- RDS database (unless final snapshot is enabled)
- Load balancers
- VPC and networking components

**Note**: If destroy fails, re-run the command. Common issues:
- ENI detachment delays
- Security group dependencies
- RDS final snapshot creation

---

## Architecture Benefits

✅ **High Availability**: Multi-AZ deployment with auto-scaling  
✅ **Security**: Private subnets, security group chaining, encrypted secrets  
✅ **Scalability**: Auto Scaling Groups respond to load automatically  
✅ **Cost Efficient**: t3.micro instances, single NAT option for dev  
✅ **Observable**: CloudWatch logs and metrics throughout  
✅ **Maintainable**: Modular Terraform, Infrastructure as Code  
✅ **Production Ready**: Follows AWS Well-Architected Framework  

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Support

For issues and questions:
- Open an issue on GitHub
- Review the [Architecture Documentation](terraform-infra/ARCHITECTURE.md)
- Check the [Quick Start Guide](terraform-infra/QUICKSTART.md)

---

**Built with ❤️ using Terraform, Docker, AWS, Node.js, and Go**
