


# Day 02: Terraform AWS Provider Explained

This document explains how Terraform providers work, how to configure the AWS provider, how version constraints work, and how to run your first Terraform commands. It also covers how to set up AWS credentials using `aws configure`.

## What Is a Terraform Provider

A provider is a plugin that connects Terraform to a cloud platform or service. It translates HCL code into the API calls that the target platform understands. When managing AWS resources, the AWS Terraform Provider handles all communication with AWS services.

Terraform downloads providers automatically when you run `terraform init`.

## Types of Providers

| Type | Maintained By | Examples |
|------|---------------|----------|
| Official | Cloud providers | AWS, Azure, GCP |
| Partner | Third parties | Vendor backed services |
| Community | Open source community | Docker, Kubernetes, Prometheus |

## Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}
````

Notes:

* Always refer to the Terraform Registry for reference.
* Do not store secrets in the provider block.
* Lock the provider version to avoid unexpected issues.

## Version Constraints

Terraform and providers are updated separately, so version control is important.

| Operator | Meaning            | Example  | Allowed Versions         |
| -------- | ------------------ | -------- | ------------------------ |
| =        | Exact match        | = 6.7.0  | Only 6.7.0               |
| !=       | Exclude version    | != 6.7.0 | Any version except 6.7.0 |
| <        | Less than          | < 6.7.0  | Below 6.7.0              |
| >        | Greater than       | > 6.7.0  | Above 6.7.0              |
| <= or >= | Comparison         | >= 6.7.0 | 6.7.0 and higher         |
| ~>       | Patch updates only | ~> 6.7   | 6.7.x only               |

## Hands On Example

Create a file named `main.tf`:

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

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}
```

Resource reference format:

```
resource_type.local_name.attribute
```

Example:

```
aws_vpc.example.id
```

## Commands to Run

### Initialize Terraform

This downloads the AWS provider plugin.

```
terraform init
```

### Configure AWS Credentials

Run:

```
aws configure
```

You will be asked to enter:

```
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format:
```

### Where Do You Get the AWS Access Key and Secret Key

You can create them in the AWS Management Console:

1. Sign in to AWS console.
2. Go to **IAM**.
3. Select **Users**.
4. Choose your user or create a new one.
5. Open the **Security Credentials** tab.
6. Under **Access Keys**, create a new access key.
7. Copy the **Access Key ID** and **Secret Access Key**.
8. Use them in the `aws configure` command.

These credentials allow Terraform to authenticate with AWS.

### Preview the Infrastructure Plan

```
terraform plan
```

Example output:

```
Plan: 1 to add, 0 to change, 0 to destroy
```

## Summary

* Providers translate Terraform code into cloud API calls.
* AWS provider is defined in the required_providers block.
* Version constraints prevent compatibility issues.
* Use terraform init to download providers.
* Use aws configure to add IAM access keys.
* Create IAM access keys from the AWS console under the Security Credentials tab.




