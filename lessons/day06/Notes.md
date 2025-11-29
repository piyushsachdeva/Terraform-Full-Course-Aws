
# Day 06 of my 30DaysTerraformWithAWSChallenge  
## Multi-File Terraform Project Structure (Hands-On Notes)

These notes show how to break a single `main.tf` into a production-ready Terraform layout. Each file has one job, follows HashiCorp’s standards and keeps the project scalable.

---

## Why Split the Project
- Easier to read and maintain  
- Team members can work in parallel  
- Cleaner Git commits  
- Ready for modules when the project grows  

---

## Final Structure

day-06-terraform-project/  
├── main.tf  
├── variables.tf  
├── locals.tf  
├── outputs.tf  
├── providers.tf  
├── versions.tf  
├── backend.tf  
├── terraform.tfvars  
├── terraform.tfvars.example  
├── .gitignore  
└── README.md  

Terraform loads every `.tf` file automatically.

---

## 1. main.tf  
All AWS resources stay here.

```tf
resource "aws_s3_bucket" "first_bucket" {
  bucket = "anjali-gupta-bucket-76"
  region = var.region
  tags = {
    Name        = "My bucket"
    Environment = var.environment
  }
}

resource "aws_vpc" "sample" {
  cidr_block = "10.0.1.0/24"
  region     = var.region

  tags = {
    Environment = var.environment
    Name        = local.vpc_name
  }
}

resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  region        = var.region

  tags = {
    Environment = var.environment
    Name        = local.instance_name
  }
}
````

---

## 2. variables.tf

All input variables in one place.

```tf
variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}
```

---

## 3. locals.tf

Reusable computed values.

```tf
locals {
  vpc_name      = "${var.environment}-VPC"
  instance_name = "${var.environment}-Instance"
}
```

---

## 4. outputs.tf

Outputs for CLI or modules.

```tf
output "instance_id" {
  value = aws_instance.example.id
}

output "vpc_id" {
  value = aws_vpc.sample.id
}
```

---

## 5. providers.tf

AWS provider details.

```tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
```

---

## 6. versions.tf

Terraform and provider version guarantees.

```tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

## 7. backend.tf

Remote state storage in S3.

```tf
terraform {
  backend "s3" {
    bucket       = "anjali-gupta-bucket-76"
    key          = "terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
```

---

## 8. .gitignore

Protect your sensitive files.

```
.terraform*
*.tfstate
*.tfstate.backup
.terraform.lock.hcl
crash.log
*.log
terraform.tfvars
*.tfvars.json
```

---

## 9. terraform.tfvars.example

Safe file to commit.

```tf
aws_region     = "us-east-1"
environment    = "dev"
bucket_name    = "my-app-bucket-123"
vpc_cidr       = "10.0.0.0/16"
ami_id         = "ami-0abcdef1234567890"
instance_type  = "t3.micro"
```

Usage:

```
cp terraform.tfvars.example terraform.tfvars
```

---

## Commands

```
terraform init
terraform plan
terraform apply
terraform destroy
```

---

## What This Setup Gives You

* Clear file responsibilities
* Cleaner workspace
* Easy onboarding for teams
* Ready for modules and multi-environment infra


