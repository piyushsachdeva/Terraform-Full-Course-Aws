
# Day 03: Create an AWS S3 Bucket Using Terraform

This repo contains my Day 03 work for the 30 Days Terraform with AWS Challenge.  
The task for today was to create an AWS S3 bucket using Terraform and understand how Terraform handles resource creation, updates and deletion.

This README covers the setup, commands, workflow and the key things I learned while building this.

---

## Project Structure

```

day03/
└── main.tf

````

---

## Terraform Code Used

Here is the exact code I wrote for creating the S3 bucket:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "first_bucket" {
  bucket = "terraform-bucket-anjalig-12345"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
````

---

## Steps to Run the Project

### 1. Initialize Terraform

This sets up the project and downloads the AWS provider.

```bash
terraform init
```



---

### 2. Preview the Execution Plan

This shows what Terraform will create before actually applying changes.

```bash
terraform plan
```



---

### 3. Apply the Configuration

This creates the S3 bucket in AWS.

```bash
terraform apply
```

Type `yes` when asked.



---

### 4. Verify the Bucket in AWS Console

Open the S3 service in the AWS Console and check for your bucket:

Bucket name: `terraform-bucket-anjalig-12345`

---

## Updating the Resource (If Needed)

Any time you change the tags or configuration, run:

```bash
terraform plan
terraform apply
```

Terraform will update the bucket in place.



---

## Destroy the Resources

To remove the bucket and clean everything:

```bash
terraform destroy
```

Type `yes` when prompted.



## What I Learned Today

* How to create an AWS S3 bucket using Terraform
* How to structure a Terraform configuration file
* The importance of unique S3 bucket names
* The full Terraform workflow: init → plan → apply → verify → destroy
* Terraform uses a state file to track created resources
* Re-running apply does not recreate the bucket unless changes are made
* How tags help organize resources inside AWS



This completes Day 03 of the challenge.
Moving next to more Terraform resource types and concepts.


