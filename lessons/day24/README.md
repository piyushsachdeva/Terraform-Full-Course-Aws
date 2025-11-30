# Day 24: High Available/Scalable Infrastructure Deployment (Mini Project 10)

## 📋 Project Overview

This project demonstrates a **production-grade, highly available Django application** deployed on AWS using Terraform Infrastructure as Code (IaC). The infrastructure spans multiple Availability Zones and automatically scales based on demand.

### 🎯 Key Features
- ✅ **High Availability**: Multi-AZ deployment with no single point of failure
- ✅ **Auto Scaling**: Dynamic scaling based on CPU utilization (1-5 instances)
- ✅ **Security**: Private instances with ALB-only access
- ✅ **Load Balancing**: Application Load Balancer distributes traffic
- ✅ **Containerized App**: Django application running in Docker
- ✅ **Infrastructure as Code**: Fully automated with Terraform

---

## 🏗️ Architecture Overview

### High-Level Architecture

```
Internet → ALB (Public Subnets) → EC2 Instances (Private Subnets) → NAT Gateways → Internet
                                         ↓
                                   Django Docker App
```

### Detailed Component Breakdown

#### 1. **VPC (Virtual Private Cloud)**
- **CIDR Block**: `10.0.0.0/16`
- **Availability Zones**: 2 (us-east-1a, us-east-1b)
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Private Subnets**: `10.0.11.0/24`, `10.0.12.0/24`

#### 2. **Internet Connectivity**
- **Internet Gateway**: Enables public subnet internet access
- **NAT Gateways**: 2 (one per AZ) - Provides outbound internet for private instances
- **Elastic IPs**: 2 (one per NAT Gateway)

#### 3. **Load Balancing Layer**
- **Application Load Balancer (ALB)**
  - Type: Internet-facing
  - Subnets: Both public subnets
  - Listener: HTTP on port 80
  - Target Group: Health checks on `/` every 30 seconds

#### 4. **Compute Layer**
- **Auto Scaling Group (ASG)**
  - Min: 1 instance
  - Desired: 2 instances
  - Max: 5 instances
  - Subnets: Both private subnets
  - Health Check: ELB with 300s grace period

- **Launch Template**
  - AMI: Ubuntu 22.04 LTS
  - Instance Type: t2.micro
  - User Data: Installs Docker and runs Django app
  - Monitoring: Enabled

#### 5. **Application**
- **Docker Container**: `itsbaivab/django-app`
- **Port Mapping**: Host:80 → Container:8000
- **Restart Policy**: Always

#### 6. **Auto Scaling Policies**

**Target Tracking Policy:**
- Maintains average CPU at 70%

**Simple Scaling Policies:**
- Scale Out: Add 1 instance when CPU > 80% for 4 minutes
- Scale In: Remove 1 instance when CPU < 20% for 4 minutes
- Cooldown: 300 seconds

#### 7. **Security Groups**

**ALB Security Group:**
```
Inbound:  HTTP(80), HTTPS(443) from 0.0.0.0/0
Outbound: All traffic
```

**App Security Group:**
```
Inbound:  HTTP(80), HTTPS(443) from ALB Security Group only
Outbound: All traffic (for NAT Gateway)
```

**SSH Security Group:**
```
Inbound:  SSH(22) from 0.0.0.0/0
Outbound: All traffic
```

---

## 📁 Modular Code Structure

The project follows Terraform best practices with modular file organization:

```
code/
├── main.tf              # Provider configuration and Terraform settings
├── variables.tf         # Input variables with defaults
├── outputs.tf           # Output values (ALB DNS, NAT IPs, etc.)
├── vpc.tf              # VPC, Subnets, IGW, NAT Gateways, Route Tables
├── security_groups.tf   # All security group definitions
├── alb.tf              # Application Load Balancer, Target Group, Listener
├── asg.tf              # Launch Template, ASG, Scaling Policies, CloudWatch Alarms
├── s3.tf               # S3 bucket for state/artifacts (optional)
└── scripts/
    └── user_data.sh     # EC2 initialization script
```

### File Responsibilities

#### `main.tf` - Core Configuration
```terraform
# Defines:
- AWS Provider
- Terraform version requirements
- Backend configuration (if using remote state)
```

#### `variables.tf` - Configuration Parameters
```terraform
# Key Variables:
- region (default: us-east-1)
- vpc_cidr (default: 10.0.0.0/16)
- availability_zones (default: [us-east-1a, us-east-1b])
- instance_type (default: t2.micro)
- min_size, max_size, desired_capacity (ASG scaling)
- ami_id (Ubuntu 22.04)
```

#### `vpc.tf` - Network Infrastructure
```terraform
# Creates:
✓ VPC with DNS support
✓ 2 Public Subnets (one per AZ)
✓ 2 Private Subnets (one per AZ)
✓ Internet Gateway
✓ 2 NAT Gateways (one per AZ) - HA Configuration
✓ 2 Elastic IPs (one per NAT Gateway)
✓ Public Route Table → Internet Gateway
✓ 2 Private Route Tables → NAT Gateways (one per subnet)
```

**High Availability Feature:**
- Each private subnet routes through its own NAT Gateway
- If AZ-1 fails, instances in AZ-2 maintain internet connectivity

#### `security_groups.tf` - Network Security
```terraform
# Creates:
✓ alb_sg: Allows HTTP/HTTPS from internet
✓ app_sg: Allows traffic ONLY from ALB (security best practice)
✓ allow_ssh: SSH access (restrict to your IP in production)
```

#### `alb.tf` - Load Balancing
```terraform
# Creates:
✓ Application Load Balancer (internet-facing)
✓ Target Group with health checks
✓ HTTP Listener (Port 80)
```

#### `asg.tf` - Auto Scaling & Monitoring
```terraform
# Creates:
✓ Launch Template with user_data script
✓ Auto Scaling Group spanning both private subnets
✓ Target Tracking Policy (70% CPU target)
✓ Simple Scaling Policies (scale out/in)
✓ CloudWatch Alarms (high/low CPU)
```

#### `scripts/user_data.sh` - Instance Bootstrap
```bash
#!/bin/bash
# Runs on every new instance launch:
1. Updates package repositories
2. Installs Docker
3. Starts Docker service
4. Pulls Django Docker image
5. Runs container with port mapping (80:8000)
```

---

## 🚀 Deployment Guide

### Prerequisites
1. **AWS Account** with appropriate permissions
2. **Terraform** installed (v1.0+)
3. **AWS CLI** configured with credentials
4. **SSH Key Pair** (optional, for debugging)

### Step-by-Step Deployment

#### 1. Initialize Terraform
```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day24/code
terraform init
```
This downloads the AWS provider and initializes the backend.

#### 2. Review the Plan
```bash
terraform plan
```
Review the resources that will be created:
- 1 VPC
- 4 Subnets (2 public, 2 private)
- 2 NAT Gateways
- 2 Elastic IPs
- 1 Application Load Balancer
- 1 Auto Scaling Group
- 3 Security Groups
- Multiple Route Tables and Associations

#### 3. Apply the Configuration
```bash
terraform apply -auto-approve
```
Deployment takes approximately **5-8 minutes**.

#### 4. Get Outputs
```bash
terraform output
```
Key outputs:
- `load_balancer_dns`: Access your application here
- `nat_gateway_ips`: Public IPs for outbound traffic
- `vpc_id`: VPC identifier

---

## ✅ Verification & Testing

### 1. Check Application Health
```bash
# Get the ALB DNS from outputs
ALB_DNS=$(terraform output -raw load_balancer_dns)

# Test the endpoint
curl http://$ALB_DNS
```

### 2. Verify Multi-AZ Deployment
```bash
# Check running instances
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=app-instance" \
  --query 'Reservations[*].Instances[*].[InstanceId,Placement.AvailabilityZone,State.Name]' \
  --output table
```
You should see instances in both `us-east-1a` and `us-east-1b`.

### 3. Test Auto Scaling
```bash
# Manually trigger scale-out
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name app-asg \
  --desired-capacity 3

# Monitor scaling activity
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg \
  --max-records 5
```

### 4. Verify Load Balancing
```bash
# Multiple requests should hit different instances
for i in {1..10}; do
  curl -s http://$ALB_DNS | grep "Instance ID" || echo "Request $i"
done
```

### 5. Check NAT Gateway High Availability
```bash
# List NAT Gateways
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,SubnetId,State]' \
  --output table
```
You should see 2 NAT Gateways in different subnets.

---

## 🛠️ Infrastructure Management

### Scaling Operations

**Manual Scaling:**
```bash
# Scale up
terraform apply -var="desired_capacity=4"

# Scale down
terraform apply -var="desired_capacity=1"
```

**Automatic Scaling:**
- Happens automatically based on CPU utilization
- Scale out at 80% CPU
- Scale in at 20% CPU

### Monitoring

**CloudWatch Metrics:**
```bash
# View CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=app-asg \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

**ALB Health Checks:**
```bash
# View target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

### Updating the Application

**To deploy a new Docker image version:**
1. Update the image tag in `user_data.sh`
2. Create a new launch template version:
   ```bash
   terraform apply
   ```
3. Refresh instances:
   ```bash
   aws autoscaling start-instance-refresh \
     --auto-scaling-group-name app-asg
   ```

---

## 🔍 Troubleshooting

### Issue: ALB returns 502/503 errors

**Diagnosis:**
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

**Common Causes:**
1. Django `ALLOWED_HOSTS` not configured
   - **Fix**: Update Django settings to include ALB DNS or use `['*']`
2. Container not running
   - **Fix**: SSH to instance and check `docker ps`
3. Security group misconfiguration
   - **Fix**: Verify app_sg allows traffic from alb_sg

### Issue: Instances not launching

**Check User Data Logs:**
```bash
# SSH to instance (requires bastion or Session Manager)
ssh ubuntu@<private-ip>

# View cloud-init logs
sudo tail -f /var/log/cloud-init-output.log
```

### Issue: No internet access from private instances

**Verify NAT Gateway:**
```bash
# Check NAT Gateway state
aws ec2 describe-nat-gateways --filter "Name=state,Values=available"

# Check route tables
aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=private-route-table-*"
```

### Issue: Auto Scaling not working

**Check CloudWatch Alarms:**
```bash
# List alarm states
aws cloudwatch describe-alarms \
  --alarm-names high-cpu-utilization low-cpu-utilization
```

---

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# Remove all resources
terraform destroy -auto-approve
```

**Resources removed:**
- All EC2 instances
- Auto Scaling Group
- Application Load Balancer
- NAT Gateways
- Elastic IPs (released)
- VPC and subnets
- Security Groups

**Time to complete**: ~5-7 minutes

---

## 💰 Cost Estimation

### Monthly Costs (us-east-1)

| Resource | Quantity | Unit Cost | Monthly Cost |
|----------|----------|-----------|--------------|
| EC2 t2.micro | 2 (avg) | $0.0116/hr | ~$17 |
| Application Load Balancer | 1 | $16.20/mo | $16.20 |
| NAT Gateway | 2 | $32.40/mo each | $64.80 |
| Data Transfer | Variable | $0.09/GB | ~$5-10 |
| **Total** | | | **~$103-108/mo** |

**Cost Optimization Tips:**
- Use single NAT Gateway (saves $32/mo, reduces HA)
- Use NAT Instance instead (cheaper but less reliable)
- Reduce desired capacity during off-hours
- Use Reserved Instances for predictable workloads

---

## 🎓 Learning Outcomes

By completing this project, you've learned:

1. **High Availability Design**
   - Multi-AZ architecture
   - Eliminating single points of failure
   - Zone-independent resource design

2. **Auto Scaling**
   - Launch Templates
   - Target Tracking vs Simple Scaling
   - CloudWatch integration

3. **Load Balancing**
   - Application Load Balancer configuration
   - Target Groups and health checks
   - Traffic distribution

4. **Network Security**
   - Public vs Private subnets
   - Security Group chaining
   - NAT Gateway for outbound traffic

5. **Infrastructure as Code**
   - Terraform modular design
   - Resource dependencies
   - State management
   - Variable parameterization

6. **Container Deployment**
   - Docker on EC2
   - User Data scripts
   - Port mapping

---

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Auto Scaling Best Practices](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-simple-step.html)
- [Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)

---

## 🤝 Contributing

To improve this project:
1. Add RDS database for persistent storage
2. Implement HTTPS with ACM certificates
3. Add CloudFront CDN
4. Integrate with Route53 for custom domain
5. Add WAF for security
6. Implement CI/CD pipeline

---

**Project Status**: ✅ Production-Ready with HA Architecture

**Last Updated**: November 30, 2025
