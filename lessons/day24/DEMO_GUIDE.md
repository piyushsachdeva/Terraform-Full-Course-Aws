# High Availability Infrastructure - Complete Demo Guide

## 📋 Table of Contents

1. [Architecture Deep Dive](#architecture-deep-dive)
2. [Component Details](#component-details)
3. [Step-by-Step Deployment](#step-by-step-deployment)
4. [Verification & Testing](#verification--testing)
5. [Infrastructure Management](#infrastructure-management)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Topics](#advanced-topics)

---

## Architecture Deep Dive

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          INTERNET                                │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────▼─────┐
                    │   User   │
                    └────┬─────┘
                         │ HTTP/HTTPS
                         │
        ┌────────────────▼───────────────┐
        │  Application Load Balancer     │  (Public Subnets)
        │  (ENIs in both AZs)            │
        └────────────────┬───────────────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
┌───────▼────────┐              ┌────────▼────────┐
│ AZ: us-east-1a │              │ AZ: us-east-1b  │
│                │              │                 │
│ Private Subnet │              │ Private Subnet  │
│ 10.0.11.0/24   │              │ 10.0.12.0/24    │
│                │              │                 │
│  ┌──────────┐  │              │  ┌──────────┐   │
│  │ EC2      │  │              │  │ EC2      │   │
│  │ Docker   │  │              │  │ Docker   │   │
│  │ Django   │  │              │  │ Django   │   │
│  └────┬─────┘  │              │  └────┬─────┘   │
│       │        │              │       │         │
│  ┌────▼─────┐  │              │  ┌────▼─────┐   │
│  │ NAT GW 1 │  │              │  │ NAT GW 2 │   │
│  └────┬─────┘  │              │  └────┬─────┘   │
└───────┼────────┘              └───────┼─────────┘
        │                               │
        └───────────────┬───────────────┘
                        │
                  ┌─────▼──────┐
                  │  Internet  │
                  │  Gateway   │
                  └────────────┘
```

### Architecture Diagram (Eraser.io)

Copy this to [Eraser.io](https://app.eraser.io/) to visualize:

```eraser
direction right

// External Components
User [icon: user]
Internet [icon: cloud]
DockerHub [icon: docker]

// VPC Architecture
VPC [icon: aws-vpc, label: "VPC (10.0.0.0/16)"] {

  // Public Subnets Layer
  Public_Subnets [label: "Public Subnets"] {
    ALB [icon: aws-application-load-balancer, label: "Application Load Balancer\n(Spans both AZs)"]
    
    Public_AZ1 [icon: aws-public-subnet, label: "Public Subnet AZ1\n10.0.1.0/24"] {
      NAT_GW_AZ1 [icon: aws-nat-gateway, label: "NAT Gateway 1"]
    }
    
    Public_AZ2 [icon: aws-public-subnet, label: "Public Subnet AZ2\n10.0.2.0/24"] {
      NAT_GW_AZ2 [icon: aws-nat-gateway, label: "NAT Gateway 2"]
    }
  }

  // Private Subnets Layer
  Private_Subnets [label: "Private Subnets"] {
    
    Private_AZ1 [icon: aws-private-subnet, label: "Private Subnet AZ1\n10.0.11.0/24"] {
      EC2_AZ1 [icon: aws-ec2, label: "EC2 Instance"]
      Django_AZ1 [icon: docker, label: "Django App\nPort 8000→80"]
    }
    
    Private_AZ2 [icon: aws-private-subnet, label: "Private Subnet AZ2\n10.0.12.0/24"] {
      EC2_AZ2 [icon: aws-ec2, label: "EC2 Instance"]
      Django_AZ2 [icon: docker, label: "Django App\nPort 8000→80"]
    }
  }
  
  // Auto Scaling Group (Logical)
  ASG [icon: aws-auto-scaling, label: "Auto Scaling Group\n(Min:1, Desired:2, Max:5)"]
}

// ===== TRAFFIC FLOWS =====

// 1. Inbound User Traffic
User > Internet : "HTTPS/HTTP Request"
Internet > ALB : "Port 80/443"

// 2. ALB Distribution
ALB > EC2_AZ1 : "Forward (Health Check: /)"
ALB > EC2_AZ2 : "Forward (Health Check: /)"

// 3. Container Execution
EC2_AZ1 > Django_AZ1 : "Runs Container\nPort Mapping 80:8000"
EC2_AZ2 > Django_AZ2 : "Runs Container\nPort Mapping 80:8000"

// 4. Auto Scaling Management
ASG > EC2_AZ1 : "Manages & Scales"
ASG > EC2_AZ2 : "Manages & Scales"

// 5. Outbound Traffic (High Availability)
EC2_AZ1 > NAT_GW_AZ1 : "Outbound (apt, docker pull)"
EC2_AZ2 > NAT_GW_AZ2 : "Outbound (apt, docker pull)"

// 6. NAT to Internet
NAT_GW_AZ1 > Internet : "Outbound Access"
NAT_GW_AZ2 > Internet : "Outbound Access"

// 7. Docker Image Pull
Internet > DockerHub : "Public Registry"
NAT_GW_AZ1 > DockerHub : "Pull itsbaivab/django-app"
NAT_GW_AZ2 > DockerHub : "Pull itsbaivab/django-app"
```

---

## Component Details

### 1. VPC (Virtual Private Cloud)

**Configuration:**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
```

**Key Features:**
- **CIDR Block**: `10.0.0.0/16` provides 65,536 IP addresses
- **DNS Support**: Enabled for internal name resolution
- **DNS Hostnames**: Instances get DNS names automatically

### 2. Subnets

**Public Subnets:**
- **Purpose**: Host ALB and NAT Gateways
- **AZ1**: `10.0.1.0/24` (256 IPs)
- **AZ2**: `10.0.2.0/24` (256 IPs)
- **Routing**: All traffic (`0.0.0.0/0`) → Internet Gateway

**Private Subnets:**
- **Purpose**: Host EC2 instances with applications
- **AZ1**: `10.0.11.0/24` (256 IPs)
- **AZ2**: `10.0.12.0/24` (256 IPs)
- **Routing**: All traffic (`0.0.0.0/0`) → NAT Gateway (in same AZ)

### 3. Internet Gateway

**Purpose**: Enables public subnets to communicate with the internet

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

### 4. NAT Gateways (High Availability Configuration)

**Why 2 NAT Gateways?**
- **Single NAT Gateway**: If AZ-1 fails, instances in AZ-2 lose internet access
- **Dual NAT Gateway**: Each AZ routes through its own NAT Gateway

**Configuration:**
```hcl
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
}
```

**Traffic Flow:**
- Private Subnet AZ1 → NAT Gateway 1 → Internet Gateway → Internet
- Private Subnet AZ2 → NAT Gateway 2 → Internet Gateway → Internet

### 5. Application Load Balancer

**How ALB Spans Multiple AZs:**

When you specify multiple subnets:
```hcl
resource "aws_lb" "app_lb" {
  subnets = [subnet-1-id, subnet-2-id]
}
```

AWS creates **Elastic Network Interfaces (ENIs)** in each subnet:
- **ENI in AZ1**: Handles traffic for that zone
- **ENI in AZ2**: Handles traffic for that zone

**DNS Resolution:**
```bash
$ nslookup app-load-balancer-123.us-east-1.elb.amazonaws.com
Address 1: 10.0.1.50 (AZ1 ENI)
Address 2: 10.0.2.50 (AZ2 ENI)
```

**Benefits:**
- If AZ1 fails, traffic goes to AZ2 ENI
- Cross-zone load balancing distributes evenly

### 6. Auto Scaling Group

**Launch Template:**
```hcl
resource "aws_launch_template" "app" {
  image_id      = "ami-0c398cb65a93047f2"  # Ubuntu 22.04
  instance_type = "t2.micro"
  user_data     = filebase64("scripts/user_data.sh")
}
```

**Auto Scaling Group:**
```hcl
resource "aws_autoscaling_group" "app_asg" {
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = [private-subnet-1, private-subnet-2]
}
```

**How ASG Distributes Instances:**
- Desired capacity = 2 → 1 instance in each AZ
- If AZ1 fails → ASG launches 2 instances in AZ2
- Instance distribution follows AZ balance strategy

### 7. Auto Scaling Policies

**Target Tracking Policy:**
```hcl
resource "aws_autoscaling_policy" "target_tracking" {
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
```
- Maintains average CPU at 70%
- AWS automatically scales up/down

**Simple Scaling Policies:**

**Scale Out:**
```hcl
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  metric_name        = "CPUUtilization"
  threshold          = "80"
  alarm_actions      = [scale_out_policy_arn]
}
```
- When CPU > 80% for 4 minutes
- Add 1 instance
- Cooldown: 300 seconds

**Scale In:**
```hcl
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  metric_name        = "CPUUtilization"
  threshold          = "20"
  alarm_actions      = [scale_in_policy_arn]
}
```
- When CPU < 20% for 4 minutes
- Remove 1 instance
- Cooldown: 300 seconds

### 8. Security Groups

**ALB Security Group:**
```hcl
resource "aws_security_group" "alb_sg" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from internet
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**App Security Group (Security Best Practice):**
```hcl
resource "aws_security_group" "app_sg" {
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Only from ALB!
  }
}
```

**Why This Matters:**
- Users **cannot** directly access EC2 instances
- All traffic **must** go through ALB
- Even if someone gets the private IP, security group blocks them

### 9. User Data Script

**Purpose**: Runs on every new instance launch

```bash
#!/bin/bash
apt-get update -y                    # Update package lists
apt-get install -y docker.io         # Install Docker
systemctl start docker               # Start Docker service
systemctl enable docker              # Enable on boot

# Run Django container
docker run -d \
  --name django-app \
  --restart always \
  -p 80:8000 \                       # Host port 80 → Container port 8000
  itsbaivab/django-app
```

**Port Mapping Explained:**
- Django listens on port **8000** inside container
- Host (EC2) exposes port **80**
- ALB sends traffic to EC2 port **80**
- Docker maps **80 → 8000**
- Django receives the request

---

## Step-by-Step Deployment

### Prerequisites Checklist

- [ ] AWS Account with administrator access
- [ ] Terraform installed (`terraform --version`)
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS credentials configured (`aws configure`)
- [ ] Git (to clone repository)

### Step 1: Initialize Terraform

```bash
cd /path/to/Terraform-Full-Course-Aws/lessons/day24/code
terraform init
```

**What happens:**
- Downloads AWS provider plugin
- Initializes backend (local state file)
- Creates `.terraform` directory
- Creates `.terraform.lock.hcl` file

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### Step 3: Review the Plan

```bash
terraform plan
```

**Resources to be created:**

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| VPC | 1 | Network isolation |
| Subnets | 4 | 2 public, 2 private |
| Internet Gateway | 1 | Public internet access |
| NAT Gateways | 2 | Private outbound access |
| Elastic IPs | 2 | For NAT Gateways |
| Route Tables | 3 | 1 public, 2 private |
| Route Table Associations | 4 | Link subnets to route tables |
| Security Groups | 3 | ALB, App, SSH |
| Application Load Balancer | 1 | Traffic distribution |
| Target Group | 1 | ALB target registration |
| Listener | 1 | ALB port 80 listener |
| Launch Template | 1 | EC2 configuration |
| Auto Scaling Group | 1 | Instance management |
| Auto Scaling Policies | 3 | Scaling rules |
| CloudWatch Alarms | 2 | Scaling triggers |
| S3 Bucket | 1 | Optional storage |

**Total Resources**: ~30+

### Step 4: Deploy Infrastructure

```bash
terraform apply -auto-approve
```

**Deployment Timeline:**

| Time | Activity |
|------|----------|
| 0:00 | VPC and subnets created |
| 0:30 | Internet Gateway attached |
| 1:00 | NAT Gateways creating (slowest) |
| 3:00 | Security groups created |
| 3:30 | ALB provisioning |
| 4:00 | Target group created |
| 4:30 | Launch template created |
| 5:00 | Auto Scaling Group launching instances |
| 6:00 | Instances running user_data script |
| 7:00 | Docker pulling image |
| 8:00 | **Deployment complete** |

**Expected Output:**
```
Apply complete! Resources: 32 added, 0 changed, 0 destroyed.

Outputs:

load_balancer_dns = "app-load-balancer-1234567890.us-east-1.elb.amazonaws.com"
nat_gateway_ips = [
  "34.123.45.67",
  "34.123.45.68",
]
vpc_id = "vpc-0abcd1234efgh5678"
```

### Step 5: Verify Outputs

```bash
terraform output
```

```bash
# Get specific output
terraform output -raw load_balancer_dns
```

---

## Verification & Testing

### 1. Application Health Check

```bash
ALB_DNS=$(terraform output -raw load_balancer_dns)
curl http://$ALB_DNS
```

**Expected Response:**
- HTTP 200 status
- HTML page from Django application

**If you see errors:**
- **502 Bad Gateway**: Instances not healthy yet (wait 2-3 minutes)
- **503 Service Unavailable**: No healthy targets
- **Connection refused**: ALB not yet provisioned

### 2. Verify Multi-AZ Deployment

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=app-instance" \
  "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,PrivateIpAddress,Placement.AvailabilityZone,State.Name]' \
  --output table
```

**Expected Output:**
```
------------------------------------------------------------
|                    DescribeInstances                      |
+-----------------------+-------------+----------+----------+
|  i-0abc123def456789  | 10.0.11.45  | us-east-1a | running |
|  i-0def456abc123789  | 10.0.12.78  | us-east-1b | running |
+------------------------+-------------+----------+----------+
```

### 3. Check Target Health

```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table
```

**Expected Output:**
```
----------------------------------------
|        DescribeTargetHealth          |
+-----------------------+--------+-----+
|  i-0abc123def456789   | healthy|     |
|  i-0def456abc123789   | healthy|     |
+-----------------------+--------+-----+
```

**Possible States:**
- **healthy**: Instance is serving traffic
- **initial**: Health check grace period (first 300 seconds)
- **unhealthy**: Failed health checks
- **draining**: Being removed from service

### 4. Test Load Balancing

```bash
for i in {1..20}; do
  echo "Request $i:"
  curl -s http://$ALB_DNS | grep -o "Instance ID: i-[a-z0-9]*" || echo "No instance ID found"
  sleep 1
done
```

**Expected**: Requests distributed between different instance IDs

### 5. Verify NAT Gateway High Availability

```bash
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,SubnetId,VpcId,NatGatewayAddresses[0].PublicIp]' \
  --output table
```

**Expected Output:**
```
--------------------------------------------------------------------
|                      DescribeNatGateways                          |
+----------------------+-------------------+----------+-------------+
|  nat-0abc123456789   | subnet-public-1  | vpc-... | 34.123.45.67|
|  nat-0def987654321   | subnet-public-2  | vpc-... | 34.123.45.68|
+----------------------+-------------------+----------+-------------+
```

### 6. Test Auto Scaling

**Manually Trigger Scale Out:**
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name app-asg \
  --desired-capacity 3

# Monitor activity
watch -n 5 'aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg \
  --max-records 5 --output table'
```

**Verify New Instance:**
```bash
aws ec2 describe-instances \
  --filters "Name=tag:aws:autoscaling:groupName,Values=app-asg" \
  "Name=instance-state-name,Values=running,pending" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table
```

**Scale Back Down:**
```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name app-asg \
  --desired-capacity 2
```

---

## Infrastructure Management

### Scaling Operations

**Change Desired Capacity via Terraform:**
```bash
terraform apply -var="desired_capacity=4"
```

**View Current Capacity:**
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names app-asg \
  --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize,Instances[*].InstanceId]' \
  --output table
```

### Monitoring with CloudWatch

**View CPU Utilization:**
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=app-asg \
  --start-time $(date -u -d '1 hour ago' --iso-8601=seconds) \
  --end-time $(date -u --iso-8601=seconds) \
  --period 300 \
  --statistics Average \
  --query 'Datapoints[*].[Timestamp,Average]' \
  --output table
```

**Check CloudWatch Alarms:**
```bash
aws cloudwatch describe-alarms \
  --alarm-names high-cpu-utilization low-cpu-utilization \
  --query 'MetricAlarms[*].[AlarmName,StateValue,StateReason]' \
  --output table
```

### Application Updates

**Method 1: Update User Data**
1. Edit `scripts/user_data.sh`
2. Run `terraform apply`
3. Manually refresh instances:
```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name app-asg \
  --preferences '{"MinHealthyPercentage": 50}'
```

**Method 2: Create New AMI**
1. Launch test instance
2. Install/configure application
3. Create AMI
4. Update `variables.tf` with new AMI ID
5. Run `terraform apply`

---

## Troubleshooting

### Issue 1: ALB Returns 502/503 Errors

**Symptoms:**
```bash
$ curl http://$ALB_DNS
<html><body><h1>502 Bad Gateway</h1></body></html>
```

**Diagnosis Steps:**

1. **Check Target Health:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

2. **Check Instance Status:**
```bash
aws ec2 describe-instance-status \
  --instance-ids $(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names app-asg \
    --query 'AutoScalingGroups[0].Instances[*].InstanceId' \
    --output text)
```

3. **Check User Data Execution (requires SSM):**
```bash
aws ssm send-command \
  --instance-ids <instance-id> \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["tail -50 /var/log/cloud-init-output.log"]'
```

**Common Causes:**

**A. Django ALLOWED_HOSTS not configured:**
```python
# Django settings.py
ALLOWED_HOSTS = ['*']  # Or add ALB DNS
```

**B. Docker container not running:**
```bash
# SSH to instance (via Session Manager or bastion)
docker ps
docker logs django-app
```

**C. Port mapping incorrect:**
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
# Should show: 0.0.0.0:80->8000/tcp
```

### Issue 2: Instances Not Launching

**Symptoms:**
- ASG shows desired capacity but no instances running
- Instances launch then immediately terminate

**Diagnosis:**

1. **Check ASG Activity:**
```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg \
  --max-records 10
```

2. **Check CloudWatch Logs (if configured):**
```bash
aws logs tail /aws/ec2/user-data --follow
```

**Common Causes:**

**A. AMI not available in region:**
```bash
aws ec2 describe-images --image-ids ami-0c398cb65a93047f2
```

**B. Insufficient capacity:**
- Try different instance type
- Request capacity increase via AWS Support

**C. User data script errors:**
```bash
# View script logs on instance
sudo tail -f /var/log/cloud-init-output.log
```

### Issue 3: No Internet Access from Private Instances

**Symptoms:**
- Docker pull fails
- `apt-get update` fails
- Cannot reach external APIs

**Diagnosis:**

1. **Check NAT Gateway State:**
```bash
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available"
```

2. **Check Route Tables:**
```bash
aws ec2 describe-route-tables \
  --filters "Name=tag:Name,Values=private-route-table-*" \
  --query 'RouteTables[*].Routes' \
  --output table
```

**Should see:**
```
Destination: 0.0.0.0/0 → NAT Gateway
Destination: 10.0.0.0/16 → local
```

3. **Test from Instance (via Session Manager):**
```bash
curl -I https://www.google.com
ping 8.8.8.8
```

**Common Causes:**

**A. NAT Gateway in wrong subnet:**
- Must be in public subnet
- Public subnet must have route to Internet Gateway

**B. Elastic IP not attached:**
```bash
aws ec2 describe-addresses \
  --filters "Name=domain,Values=vpc"
```

**C. Security group blocking outbound:**
```bash
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw app_security_group_id) \
  --query 'SecurityGroups[*].IpPermissionsEgress'
```

### Issue 4: Auto Scaling Not Working

**Symptoms:**
- CPU spikes but no new instances launched
- Alarms triggering but ASG not responding

**Diagnosis:**

1. **Check CloudWatch Alarms:**
```bash
aws cloudwatch describe-alarms \
  --alarm-names high-cpu-utilization low-cpu-utilization
```

2. **Check Scaling Activities:**
```bash
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name app-asg \
  --max-records 20
```

3. **View Scaling Policies:**
```bash
aws autoscaling describe-policies \
  --auto-scaling-group-name app-asg
```

**Common Causes:**

**A. Cooldown period active:**
- Default: 300 seconds between scaling actions
- Check StatusCode in scaling activities

**B. Already at max capacity:**
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names app-asg \
  --query 'AutoScalingGroups[0].[DesiredCapacity,MaxSize]'
```

**C. Insufficient EC2 capacity:**
- Try different instance type or AZ

---

## Advanced Topics

### High Availability Best Practices

**1. Multi-Region Deployment**
```hcl
# Deploy in multiple regions
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

provider "aws" {
  region = "us-west-2"
  alias  = "secondary"
}
```

**2. Health Check Tuning**
```hcl
resource "aws_lb_target_group" "app_tg" {
  health_check {
    path                = "/health"  # Custom health endpoint
    interval            = 15         # Check every 15 seconds
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
```

**3. Connection Draining**
```hcl
resource "aws_lb_target_group" "app_tg" {
  deregistration_delay = 30  # Wait 30s before removing instance
}
```

### Security Hardening

**1. Restrict SSH Access:**
```hcl
resource "aws_security_group" "allow_ssh" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]  # Replace with your IP
  }
}
```

**2. Enable HTTPS:**
```hcl
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn
}
```

**3. Add WAF:**
```hcl
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.app_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
```

### Cost Optimization

**1. Reserved Instances:**
```bash
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id <offering-id> \
  --instance-count 2
```

**2. Spot Instances:**
```hcl
resource "aws_autoscaling_group" "app_asg" {
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }
  }
}
```

**3. Schedule-Based Scaling:**
```hcl
resource "aws_autoscaling_schedule" "scale_down_evening" {
  scheduled_action_name  = "scale-down-evening"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  recurrence             = "0 22 * * *"  # 10 PM daily
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}
```

### Monitoring & Alerting

**1. Custom CloudWatch Dashboard:**
```bash
aws cloudwatch put-dashboard \
  --dashboard-name "HA-Infrastructure" \
  --dashboard-body file://dashboard.json
```

**2. SNS Notifications:**
```hcl
resource "aws_sns_topic" "alerts" {
  name = "infrastructure-alerts"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

**3. AWS X-Ray Tracing:**
```hcl
resource "aws_launch_template" "app" {
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get install -y aws-xray-daemon
    systemctl start xray
  EOF
  )
}
```

---

## Learning Outcomes

By completing this guide, you've learned:

✅ **High Availability Design**
- Multi-AZ architecture patterns
- Eliminating single points of failure
- Zone-independent resource design
- Cross-AZ load balancing

✅ **Auto Scaling**
- Launch Template configuration
- Target Tracking vs Simple Scaling policies
- CloudWatch integration and alarms
- Instance lifecycle management

✅ **Load Balancing**
- ALB architecture and ENIs
- Target Group health checks
- Cross-zone traffic distribution
- Connection draining

✅ **Network Security**
- VPC design (public vs private subnets)
- Security Group chaining
- NAT Gateway architecture
- Least privilege access

✅ **Infrastructure as Code**
- Terraform modular design
- Resource dependencies and ordering
- State management
- Variable parameterization
- Output values

✅ **Container Deployment**
- Docker on EC2
- User Data script automation
- Port mapping strategies
- Container lifecycle management

---

## Additional Resources

### AWS Documentation
- [VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)
- [Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Terraform
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Tools
- [Eraser.io](https://app.eraser.io/) - Architecture diagrams
- [CloudCraft](https://www.cloudcraft.co/) - AWS architecture visualizer

---

**Guide Version**: 1.0 | **Last Updated**: December 1, 2025
