

# Day 04 – Terraform Remote State Management Using AWS S3

This document covers how Terraform stores state, why it matters, and how to move the state file to an S3 remote backend. The goal for today is to understand the purpose of the state file and set up a secure and reliable backend using your own S3 bucket.

---

## What Terraform State Represents

Terraform uses a file named `terraform.tfstate` to remember the current condition of your infrastructure. This includes metadata, resource details, identifiers and other sensitive values.

Terraform compares the desired state in your configuration with the actual state stored in this file to decide what changes are needed. Without the state file, Terraform would need to scan everything on your cloud account, which would be slow and inefficient.

---

## Why Local State Is a Problem

Local state files are stored on your system. That can cause several issues:

* no collaboration between team members
* state loss if the file is deleted or corrupted
* secrets exposed if your system is compromised
* no versioning or recovery

For real world work, the state file should never be kept locally.

---

## Benefits of Using a Remote Backend

A remote backend solves these limitations by keeping the state in a shared and secure location. Using an S3 bucket gives you:

* central storage
* automatic locking to avoid conflicts
* versioning and recovery
* safer handling of sensitive data
* better collaboration

---

## Backend Bucket Setup

Create the backend bucket manually before running Terraform.

Bucket details for this project:

```
Bucket Name: anjali-gupta-bucket-76
Region: eu-north-1
```

Do not create this bucket inside Terraform. Terraform needs the bucket to exist before it can configure the backend.

---

## Backend Configuration

Here is the backend block used for this project:

```hcl
terraform {
  backend "s3" {
    bucket        = "anjali-gupta-bucket-76"
    key           = "terraform.tfstate"
    region        = "eu-north-1"
    use_lockfile  = true
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
```

This setup tells Terraform to store the state file in your S3 bucket and enable lockfile support for safe operations.

---

## Initialization Steps

After creating the bucket and writing your configuration:

```
terraform init
terraform plan
terraform apply
```

During initialization, Terraform uploads the local state (if any) to S3.

---

## Verifying the Remote State

Open the AWS console and check:

```
S3 → anjali-gupta-bucket-76 → terraform.tfstate
```

You should find the state file stored there.

---

## Useful Terraform State Commands

List managed resources:

```
terraform state list
```

Inspect a resource:

```
terraform state show <resource_name>
```

Download a copy of the current state:

```
terraform state pull
```

---

## Recommended Practices

* never modify the state file by hand
* always keep the backend bucket outside Terraform
* enable versioning on the S3 bucket
* maintain different state keys for dev, test and prod
* enable locking to avoid parallel updates

These steps help prevent corruption and keep your workflow stable.

---

## What You Completed Today

* Learned how Terraform tracks infrastructure
* Understood the role and risks of the local state file
* Set up a secure S3 remote backend
* Enabled safe and reliable state locking
* Verified the state stored in S3
* Practiced state commands for inspection and debugging


