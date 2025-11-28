
# Day 5: Terraform Variables – Input, Local, and Output Variables

This document covers why variables are used in Terraform, the different types available, how they work, and how to apply them correctly in a real AWS setup.

---

## Why We Need Variables

When infrastructure grows, repeating the same values across multiple resources causes errors and makes the code hard to maintain.

Variables help by:
- Removing duplicate values across configurations  
- Keeping environments consistent (dev, stage, prod)  
- Allowing easy updates by changing a single value  
- Reducing human errors like typos or mismatched names  

---

## Types of Variables in Terraform

Terraform supports three important variable categories:

1. **Input Variables**  
   Values passed by the user or from `.tfvars` files.  
   Used for environment, region, instance types, names, and anything that changes across setups.

2. **Local Variables**  
   Internal computed values used within a module.  
   Useful for naming patterns and reusable strings.

3. **Output Variables**  
   Values printed after `terraform apply` or shared with other modules.  
   Helps fetch resource IDs like VPC, EC2, or S3.

---

## Input Variables

Input variables make your configuration flexible and environment-agnostic.

Example:
```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}
````

---

## Local Variables

Locals are ideal for building consistent resource names.

Example:

```hcl
locals {
  vpc_name       = "${var.environment}-VPC"
  instance_name  = "${var.environment}-Instance"
}
```

This avoids repeating naming logic in all resources.

---

## Output Variables

Outputs allow you to view important IDs after execution.

Example:

```hcl
output "instance_id" {
  value = aws_instance.example.id
}

output "vpc_id" {
  value = aws_vpc.sample.id
}
```

---

## Variable Precedence (Highest to Lowest)

1. CLI `-var` flag
2. terraform.tfvars
3. Environment variables
4. Default values inside `variable` blocks

Terraform always picks the highest-priority value.

---

## Complete Working Example (With AWS Backend)

```hcl
terraform {

    backend "s3" {
        bucket       = "anjali-gupta-bucket-76"
        key          = "terraform.tfstate"
        region       = "eu-north-1"
        use_lockfile = true
    }

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

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

locals {
  vpc_name       = "${var.environment}-VPC"
  instance_name  = "${var.environment}-Instance"
}

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

output "instance_id" {
  value = aws_instance.example.id
}

output "vpc_id" {
  value = aws_vpc.sample.id
}
```

---

## Best Practices

* Use input variables for anything environment-specific
* Use locals for naming conventions and computed values
* Avoid hardcoding values in resources
* Keep sensitive values out of the code
* Store defaults in terraform.tfvars
* Always review variable precedence
* Use outputs for IDs you need later

---

## Common Mistakes to Avoid

* Hardcoding region or environment inside resources
* Repeating naming logic
* Using invalid AMI IDs
* Missing IAM permissions
* Forgetting to configure backend state

---

## Commands to Run

```
terraform init  
terraform plan  
terraform apply  
terraform output  
terraform destroy  
```

---

## Extra Notes

* Always verify AMI IDs in your AWS region.
* Use locals when naming multiple resources to stay consistent.
* Use S3 backend for persistent and shared state.

---

## Reference and Credits

Big shoutout to **Piyush Sachdeva** for the guidance and resources.
Blog link: [https://terraformprovider.hashnode.dev]([https://terraformprovider.hashnode.dev](https://terraformlacwithawschallenge.hashnode.dev/day05-terraform-variables))

```


