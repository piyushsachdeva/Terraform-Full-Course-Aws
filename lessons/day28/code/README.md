# AWS Production Infrastructure - Demo Guide

## 🎯 Overview

This demo guide walks you through deploying a production-grade 2-tier AWS infrastructure using Terraform. The infrastructure includes:

- **VPC** with public and private subnets across multiple AZs
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with dynamic scaling policies
- **NAT Gateway** for secure private subnet internet access
- **Security Groups** with proper network isolation
- **S3 Bucket** for static assets and logs
- **EC2 instances** running Nginx web servers

## 📋 Prerequisites

Before starting this demo, ensure you have:

1. **Terraform** (>= 1.0) installed
   ```bash
   terraform version
   ```

2. **AWS CLI** configured with credentials
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and default region
   ```

3. **IAM Permissions** - Your AWS user needs permissions to create:
   - VPC, Subnets, Internet Gateway, NAT Gateway
   - EC2 instances, Auto Scaling Groups, Launch Templates
   - Application Load Balancer, Target Groups
   - Security Groups, Network ACLs
   - S3 Buckets
   - Elastic IPs

4. **AWS Account** with sufficient service quotas for the region

## 🏗️ Architecture Components

### Network Layer
- **VPC**: `10.0.0.0/16` CIDR block
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24` (AZ-a, AZ-b)
- **Private Subnets**: `10.0.11.0/24`, `10.0.12.0/24` (AZ-a, AZ-b)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access

### Compute Layer
- **Auto Scaling Group**: 2-6 instances based on CPU utilization
- **Launch Template**: Ubuntu-based EC2 instances with Nginx
- **Instance Type**: t2.micro (configurable)

### Load Balancing
- **Application Load Balancer**: Distributes traffic across healthy instances
- **Target Group**: Health checks on port 80
- **Listener**: HTTP on port 80

### Storage
- **S3 Bucket**: For application assets and ALB logs

## 🚀 Step-by-Step Demo

### Step 1: Clone and Navigate

```bash
# If not already in the directory
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day20/code
```

### Step 2: Review Configuration Files

```bash
# View the main configuration
cat main.tf

# Check variables and their default values
cat variables.tf

# See what outputs will be displayed
cat outputs.tf
```

### Step 3: (Optional) Customize Variables

Create a `terraform.tfvars` file to override defaults:

```bash
cat > terraform.tfvars << EOF
region      = "us-east-1"
environment = "demo"
instance_type = "t2.micro"
min_size    = 2
max_size    = 4
desired_capacity = 2
EOF
```

### Step 4: Initialize Terraform

```bash
terraform init
```

**Expected Output:**
- Downloads AWS and Random providers
- Initializes backend
- Shows "Terraform has been successfully initialized!"

### Step 5: Validate Configuration

```bash
terraform validate
```

**Expected Output:** `Success! The configuration is valid.`

### Step 6: Plan the Deployment

```bash
terraform plan -out=tfplan
```

**What to Look For:**
- Total resources to be created (~30-35 resources)
- VPC, subnets, and networking components
- Security groups and rules
- Load balancer and target group
- Auto Scaling Group and launch template
- S3 bucket configuration

### Step 7: Apply the Configuration

```bash
terraform apply tfplan
```

**Duration:** Approximately 5-7 minutes

**What's Happening:**
1. VPC and networking setup (1 min)
2. Security groups creation (30 sec)
3. NAT Gateway allocation (2 min)
4. Load balancer provisioning (2 min)
5. Auto Scaling Group launch (1-2 min)
6. S3 bucket creation (10 sec)

### Step 8: Verify Outputs

After successful apply, you'll see:

```
Outputs:

load_balancer_dns = "app-lb-123456789.us-east-1.elb.amazonaws.com"
s3_bucket_name = "my-app-bucket-xxxxx"
vpc_id = "vpc-xxxxxxxxxxxxx"
public_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
private_subnet_ids = ["subnet-zzzzz", "subnet-aaaaa"]
```

### Step 9: Test the Application

```bash
# Get the load balancer DNS
ALB_DNS=$(terraform output -raw load_balancer_dns)

# Wait for instances to become healthy (2-3 minutes)
echo "Waiting for instances to be ready..."
sleep 180

# Test the application
curl http://$ALB_DNS
```

**Expected Output:**
```html
<h1>Welcome to the AWS Infrastructure Project - Proper 2-Tier Architecture (Ubuntu)</h1>
```

### Step 10: Test in Browser

```bash
echo "Access your application at: http://$ALB_DNS"
```

Open the URL in your browser to see the Nginx welcome page.

## 🔍 Verification Steps

### Check Auto Scaling Group

```bash
# List EC2 instances in the ASG
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(AutoScalingGroupName, 'app-asg')].Instances[*].[InstanceId, HealthStatus, AvailabilityZone]" \
  --output table
```

### Check Load Balancer Health

```bash
# Get target group ARN
TG_ARN=$(aws elbv2 describe-target-groups \
  --query "TargetGroups[?contains(TargetGroupName, 'app-tg')].TargetGroupArn" \
  --output text)

# Check target health
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```

### Monitor S3 Bucket

```bash
# List S3 bucket
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 ls s3://$S3_BUCKET/
```

### Check VPC Resources

```bash
# View VPC details
VPC_ID=$(terraform output -raw vpc_id)
aws ec2 describe-vpcs --vpc-ids $VPC_ID

# View subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch]" --output table
```

## 🧪 Testing Auto Scaling

### Trigger Scale-Up Event

```bash
# Generate load on the application (requires Apache Bench)
sudo apt-get install -y apache2-utils
ab -n 10000 -c 100 http://$ALB_DNS/

# Watch for new instances
watch -n 10 'aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, '\''app-asg'\'')].{Desired:DesiredCapacity,Current:length(Instances),Min:MinSize,Max:MaxSize}" --output table'
```

### Monitor Scaling Activity

```bash
# View scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name $(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, 'app-asg')].AutoScalingGroupName" --output text) \
  --max-records 5
```

## 📊 Cost Estimation

**Approximate monthly costs (us-east-1):**
- EC2 (t2.micro × 2): ~$15
- ALB: ~$20
- NAT Gateway: ~$35
- Data transfer: ~$10
- S3: <$1
- **Total: ~$80/month**

**Demo costs:** If destroyed within 1 hour: ~$0.15

## 🧹 Cleanup

### Step 1: View Resources to be Destroyed

```bash
terraform plan -destroy
```

### Step 2: Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

**Duration:** Approximately 5-7 minutes

**Note:** NAT Gateway can take 3-5 minutes to fully delete.

### Step 3: Verify Cleanup

```bash
# Check if resources are deleted
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=AWS-Production-Infrastructure"
```

## 🐛 Troubleshooting

### Issue: Instances Not Healthy

**Solution:**
```bash
# Check security group rules
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=AWS-Production-Infrastructure"

# Verify user data script execution
# SSH into instance (if key pair configured) and check:
sudo systemctl status nginx
sudo tail -f /var/log/cloud-init-output.log
```

### Issue: ALB Returns 503

**Possible Causes:**
- Instances still launching (wait 3-5 minutes)
- Security group blocking traffic
- Health check failing

**Solution:**
```bash
# Check target health
TG_ARN=$(aws elbv2 describe-target-groups --query "TargetGroups[0].TargetGroupArn" --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```

### Issue: Terraform Apply Fails

**Solution:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify quotas
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A

# Review detailed error
terraform apply -refresh=true
```

### Issue: NAT Gateway Costs

**Solution:** For demo purposes, you can skip NAT Gateway by:
- Comment out NAT Gateway in `vpc.tf`
- Place instances in public subnets (not recommended for production)

## 📝 Key Learning Points

1. **Infrastructure as Code:** All resources defined declaratively
2. **High Availability:** Multi-AZ deployment ensures fault tolerance
3. **Auto Scaling:** Dynamic capacity based on demand
4. **Security:** Network isolation with public/private subnets
5. **Load Balancing:** Traffic distribution and health monitoring
6. **State Management:** Terraform tracks infrastructure state

## 🔗 Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)

## 📧 Support

For issues or questions, please check:
- AWS CloudWatch logs for runtime errors
- Terraform state: `terraform show`
- AWS Console for resource status

---

**Demo Duration:** 15-20 minutes (including deployment and testing)
**Difficulty Level:** Intermediate
**Last Updated:** November 2025
- Modify the `variables.tf` file to customize the configuration as needed.