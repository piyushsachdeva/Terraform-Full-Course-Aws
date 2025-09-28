# Day 5/28 - Terraform Variables Demo

A simple demo showing the three types of Terraform variables using a basic S3 bucket.

## 🎯 Three Types of Variables

### 1. **Input Variables** (`variables.tf`)
Values you provide to Terraform - like function parameters
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}
```

### 2. **Local Variables** (`locals.tf`)
Internal computed values - like local variables in programming
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "Terraform-Demo"
  }
  
  full_bucket_name = "${var.environment}-${var.bucket_name}-${random_string.suffix.result}"
}
```

### 3. **Output Variables** (`output.tf`)
Values returned after deployment - like function return values
```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.bucket
}
```

## 🏗️ What This Creates

Just one simple S3 bucket that demonstrates all three variable types:
- Uses **input variables** for environment and bucket name
- Uses **local variables** for computed bucket name and tags
- Uses **output variables** to show the created bucket details

## 🚀 Variable Precedence Testing

### 1. **Default Values** (temporarily hide terraform.tfvars)
```bash
mv terraform.tfvars terraform.tfvars.backup
terraform plan
# Uses: environment = "staging" (from variables.tf default)
mv terraform.tfvars.backup terraform.tfvars  # restore
```

### 2. **Using terraform.tfvars** (automatically loaded)
```bash
terraform plan
# Uses: environment = "demo" (from terraform.tfvars)
```

### 3. **Command Line Override** (highest precedence)
```bash
terraform plan -var="environment=production"
# Overrides tfvars: environment = "production"
```

### 4. **Environment Variables**
```bash
export TF_VAR_environment="staging-from-env"
terraform plan
# Uses environment variable (but command line still wins)
```

### 5. **Using Different tfvars Files**
```bash
terraform plan -var-file="dev.tfvars"        # environment = "development"
terraform plan -var-file="production.tfvars"  # environment = "production"
```
```

## 📁 Simple File Structure

```
├── main.tf           # S3 bucket resource
├── variables.tf      # Input variables (2 simple variables)
├── locals.tf         # Local variables (tags and computed name)
├── output.tf         # Output variables (bucket details)
├── provider.tf       # AWS provider
├── terraform.tfvars  # Default variable values
└── README.md         # This file
```

## 🔧 Try These Commands

```bash
# Initialize
terraform init

# Plan with defaults
terraform plan

# Plan with command line override
terraform plan -var="environment=test"

# Plan with different tfvars file
terraform plan -var-file="dev.tfvars"

# Apply and see outputs
terraform apply
terraform output

# Clean up
terraform destroy
```

## 💡 Key Takeaways

- **Input variables**: Parameterize your configuration
- **Local variables**: Compute and reuse values
- **Output variables**: Share results after deployment
- **Precedence**: Command line > tfvars > environment vars > defaults

This simple example shows exactly how the video explains variables - clear, focused, and easy to understand!
