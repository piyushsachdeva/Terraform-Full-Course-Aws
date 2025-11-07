# Terraform Data Sources Demo Guide - Day 13

## Overview
This guide provides step-by-step instructions for demonstrating Terraform data sources in AWS. You'll learn how to reference and use existing infrastructure resources without managing them in your Terraform configuration.

---

## What You'll Learn

- How to use `data` blocks to query existing AWS resources
- Filtering resources using tags and other attributes
- Referencing data source outputs in resource configurations
- Best practices for working with shared infrastructure
- The difference between managing resources vs. referencing them

---

## Initial Setup

```powershell
cd C:\repos\Terraform-Full-Course-Aws\lessons\day13\code
```

---

## Architecture Overview

```
┌─────────────────────────────────────────┐
│  Pre-existing Infrastructure (Setup)   │
│  ┌─────────────────────────────────┐   │
│  │ VPC: shared-network-vpc         │   │
│  │ CIDR: 10.0.0.0/16               │   │
│  │  ┌──────────────────────────┐   │   │
│  │  │ Subnet: shared-primary-  │   │   │
│  │  │ subnet                    │   │   │
│  │  │ CIDR: 10.0.1.0/24        │   │   │
│  │  └──────────────────────────┘   │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
                    ↓
         ┌──────────────────────┐
         │  Data Sources Query  │
         │  - aws_vpc           │
         │  - aws_subnet        │
         │  - aws_ami           │
         └──────────────────────┘
                    ↓
         ┌──────────────────────┐
         │  New EC2 Instance    │
         │  - Uses existing VPC │
         │  - Uses existing     │
         │    subnet            │
         │  - Latest AMI        │
         └──────────────────────┘
```

---

## Part 1: Understanding Data Sources

### What Are Data Sources?

Data sources allow Terraform to **read** information about existing infrastructure. They:
- Don't create, update, or delete resources
- Allow you to reference resources managed elsewhere
- Enable sharing infrastructure between teams
- Are defined with `data` blocks instead of `resource` blocks

### Key Difference: Data vs. Resource

```hcl
# Resource Block - Terraform MANAGES this
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Data Block - Terraform READS this
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["shared-network-vpc"]
  }
}
```

---

## Part 2: Create Pre-existing Infrastructure

### Step 1: Navigate to Setup Directory

```powershell
cd setup
```

### Step 2: Review Setup Configuration

**Show `setup/main.tf`:**

```hcl
# This simulates infrastructure created by another team
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "shared" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "shared-network-vpc"  # ← This tag is important!
  }
}

resource "aws_subnet" "shared" {
  vpc_id     = aws_vpc.shared.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "shared-primary-subnet"  # ← This tag is important!
  }
}
```

**Key Points to Explain:**
- These resources represent infrastructure already in AWS
- The `Name` tags are crucial for our data sources to find them
- In real scenarios, you wouldn't manage these; they'd already exist

### Step 3: Initialize and Apply Setup

```powershell
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

```powershell
terraform plan
```

**Point out in the plan:**
- 2 resources will be created (VPC and Subnet)
- Note the CIDR blocks and tag names

```powershell
terraform apply -auto-approve
```

**Expected Output:**
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### Step 4: Verify in AWS Console (Optional)

1. Go to AWS VPC Console
2. Find VPC named `shared-network-vpc`
3. Check subnet named `shared-primary-subnet`
4. Note their IDs (we'll see Terraform find these)

---

## Part 3: Using Data Sources

### Step 1: Navigate Back to Main Code

```powershell
cd ..
```

You should now be in: `C:\repos\Terraform-Full-Course-Aws\lessons\day13\code`

### Step 2: Review Data Source Configuration

**Show `main.tf` - Data Source #1: VPC**

```hcl
# Data source to get the existing VPC
data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["shared-network-vpc"]
  }
}
```

**Explain:**
- `data "aws_vpc"` - reads VPC information from AWS
- `filter` - searches for VPC with specific tag
- `"shared"` - local name to reference this data source
- Returns: VPC ID, CIDR block, and other attributes

**Show `main.tf` - Data Source #2: Subnet**

```hcl
# Data source to get the existing subnet
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["shared-primary-subnet"]
  }
  vpc_id = data.aws_vpc.shared.id  # ← Using first data source!
}
```

**Explain:**
- Searches for subnet with specific tag
- `vpc_id` - narrows search to our VPC
- Demonstrates chaining data sources

**Show `main.tf` - Data Source #3: AMI**

```hcl
# Data source for the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

**Explain:**
- `most_recent = true` - gets latest matching AMI
- `owners = ["amazon"]` - only official Amazon AMIs
- Multiple filters for precise matching
- Wildcards (`*`) allow flexible pattern matching

**Show `main.tf` - Using Data Sources in Resources**

```hcl
resource "aws_instance" "main" {
  ami           = data.aws_ami.amazon_linux_2.id      # ← Data source
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.shared.id           # ← Data source
  private_ip    = "10.0.1.50"

  tags = {
    Name = "day13-instance"
  }
}
```

**Explain:**
- `data.aws_ami.amazon_linux_2.id` - references AMI data source
- `data.aws_subnet.shared.id` - references subnet data source
- Instance will be created in existing infrastructure
- Private IP must be within subnet's CIDR range

### Step 3: Initialize Terraform

```powershell
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 4: Test Data Sources in Console

**Launch console:**

```powershell
terraform console
```

**Test queries:**

```hcl
# Query VPC data source
data.aws_vpc.shared.id
data.aws_vpc.shared.cidr_block

# Query Subnet data source
data.aws_subnet.shared.id
data.aws_subnet.shared.cidr_block
data.aws_subnet.shared.availability_zone

# Query AMI data source
data.aws_ami.amazon_linux_2.id
data.aws_ami.amazon_linux_2.name
data.aws_ami.amazon_linux_2.description

# Exit console
exit
```

**Point out:**
- Data sources return actual values from AWS
- You can see IDs, CIDR blocks, and other attributes
- These values are read-only; Terraform doesn't manage them

### Step 5: Plan the Deployment

```powershell
terraform plan
```

**Key Points in the Plan:**

```
Terraform will perform the following actions:

  # aws_instance.main will be created
  + resource "aws_instance" "main" {
      + ami           = "ami-xxxxxxxxx"  # ← From data source
      + subnet_id     = "subnet-xxxxxxx"  # ← From data source
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Explain:**
- Only **1 resource** will be created (the EC2 instance)
- VPC and subnet are **not** in the plan (they already exist)
- AMI ID is automatically populated
- Subnet ID is automatically populated

### Step 6: Apply the Configuration

```powershell
terraform apply -auto-approve
```

**Expected Output:**
```
aws_instance.main: Creating...
aws_instance.main: Still creating... [10s elapsed]
aws_instance.main: Creation complete after 30s [id=i-xxxxxxxxx]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Step 7: View Outputs

```powershell
terraform output
```

**If you want to add outputs, show them in `outputs.tf`:**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = aws_instance.main.private_ip
}

output "vpc_id" {
  description = "VPC ID from data source"
  value       = data.aws_vpc.shared.id
}

output "subnet_id" {
  description = "Subnet ID from data source"
  value       = data.aws_subnet.shared.id
}

output "ami_id" {
  description = "AMI ID used for instance"
  value       = data.aws_ami.amazon_linux_2.id
}
```

### Step 8: Verify in AWS Console

**EC2 Console:**
1. Navigate to EC2 → Instances
2. Find instance named `day13-instance`
3. Check:
   - VPC ID matches `shared-network-vpc`
   - Subnet ID matches `shared-primary-subnet`
   - Private IP is `10.0.1.50`
   - AMI is Amazon Linux 2

**Alternative - Use AWS CLI:**

```powershell
# Get instance details
aws ec2 describe-instances --filters "Name=tag:Name,Values=day13-instance" --query 'Reservations[0].Instances[0].[InstanceId,PrivateIpAddress,SubnetId,ImageId]' --output table
```

---

## Part 4: Understanding Data Source Behavior

### Experiment 1: Data Source Refresh

**Test what happens when you run plan again:**

```powershell
terraform plan
```

**Expected:**
```
No changes. Your infrastructure matches the configuration.
```

**Explain:**
- Data sources are queried every time you run Terraform
- If the underlying resources change, data sources reflect that
- This ensures you always work with current information

### Experiment 2: What If Resources Don't Exist?

**Simulate missing resource:**

```powershell
# Comment out the VPC filter in main.tf temporarily
# Change "shared-network-vpc" to "non-existent-vpc"
```

**Run plan:**

```powershell
terraform plan
```

**Expected Error:**
```
Error: no matching VPC found
```

**Explain:**
- Data sources fail if they can't find matching resources
- This protects you from deploying to wrong infrastructure
- Always validate your filters match existing resources

**Revert the change before continuing!**

### Experiment 3: Multiple Matches

**Explain what happens if multiple resources match:**
- If multiple VPCs have the same tag, data source fails
- Use more specific filters or unique identifiers
- Best practice: use unique tags or IDs for data sources

---

## Part 5: Advanced Data Source Patterns

### Pattern 1: Using Resource IDs Directly

Instead of tags, you can use specific IDs:

```hcl
data "aws_vpc" "shared" {
  id = "vpc-12345678"  # Direct ID lookup
}
```

**Pros:** Faster, more precise
**Cons:** Less flexible, harder to maintain

### Pattern 2: Multiple Filters

```hcl
data "aws_subnet" "shared" {
  filter {
    name   = "tag:Name"
    values = ["shared-primary-subnet"]
  }
  
  filter {
    name   = "tag:Environment"
    values = ["production"]
  }
  
  vpc_id = data.aws_vpc.shared.id
}
```

**Benefits:** More precise matching, reduces errors

### Pattern 3: Default Values with Conditionals

```hcl
locals {
  vpc_id = try(data.aws_vpc.shared.id, var.default_vpc_id)
}
```

**Use case:** Fallback when data source might not find resources

---

## Part 6: Real-World Scenarios

### Scenario 1: Multi-Team Environment

**Team A:** Manages networking (VPC, subnets)
**Team B:** Deploys applications (EC2, RDS)

Team B uses data sources to reference Team A's infrastructure:

```hcl
data "aws_vpc" "company_vpc" {
  filter {
    name   = "tag:ManagedBy"
    values = ["networking-team"]
  }
}
```

### Scenario 2: Shared Services

**Security Team:** Manages security groups centrally
**App Teams:** Reference them in deployments

```hcl
data "aws_security_group" "company_default" {
  filter {
    name   = "tag:Name"
    values = ["company-default-sg"]
  }
}

resource "aws_instance" "app" {
  # ... other config ...
  vpc_security_group_ids = [data.aws_security_group.company_default.id]
}
```

### Scenario 3: Dynamic AMI Selection

Always use latest approved AMI:

```hcl
data "aws_ami" "approved_base" {
  most_recent = true
  owners      = ["self"]  # Your account only
  
  filter {
    name   = "tag:Approved"
    values = ["true"]
  }
}
```

---

## Part 7: Common Data Sources Reference

### Network Resources

```hcl
# VPC
data "aws_vpc" "main" { ... }

# Subnet
data "aws_subnet" "main" { ... }

# Route Table
data "aws_route_table" "main" { ... }

# Security Group
data "aws_security_group" "main" { ... }
```

### Compute Resources

```hcl
# AMI
data "aws_ami" "main" { ... }

# EC2 Instance
data "aws_instance" "main" { ... }

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}
```

### Identity and Access

```hcl
# Current AWS Account
data "aws_caller_identity" "current" {}

# Current AWS Region
data "aws_region" "current" {}

# IAM Policy
data "aws_iam_policy" "main" { ... }
```

### Storage and Database

```hcl
# S3 Bucket
data "aws_s3_bucket" "main" { ... }

# RDS Instance
data "aws_db_instance" "main" { ... }
```

---

## Part 8: Cleanup

### Step 1: Destroy the EC2 Instance

```powershell
# Ensure you're in the code directory
cd C:\repos\Terraform-Full-Course-Aws\lessons\day13\code

terraform destroy -auto-approve
```

**Expected Output:**
```
aws_instance.main: Destroying... [id=i-xxxxxxxxx]
aws_instance.main: Destruction complete after 30s

Destroy complete! Resources: 1 destroyed.
```

### Step 2: Destroy the Setup Infrastructure

```powershell
cd setup

terraform destroy -auto-approve
```
