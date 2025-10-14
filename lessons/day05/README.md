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

## 📥 Understanding Input Variables in Detail

### What are Input Variables?
Input variables are like **function parameters** - they allow you to customize your Terraform configuration without hardcoding values.

### Basic Input Variable Structure
```hcl
variable "variable_name" {
  description = "What this variable is for"
  type        = string
  default     = "default_value"  # Optional
}
```

### How to Use Input Variables
```hcl
# Define in variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "my-terraform-bucket"
}

# Reference with var. prefix in main.tf
resource "aws_s3_bucket" "demo" {
  bucket = var.bucket_name  # Using input variable
  
  tags = {
    Environment = var.environment  # Using input variable
  }
}
```

### Providing Values to Input Variables

**1. Default values** (in variables.tf)
```hcl
variable "environment" {
  default = "staging"
}
```

**2. terraform.tfvars file** (auto-loaded)
```hcl
environment = "demo"
bucket_name = "terraform-demo-bucket"
```

**3. Command line**
```bash
terraform plan -var="environment=production"
```

**4. Environment variables**
```bash
export TF_VAR_environment="development"
terraform plan
```

## 📤 Understanding Output Variables in Detail

### What are Output Variables?
Output variables are like **function return values** - they display important information after Terraform creates your infrastructure.

### Basic Output Variable Structure
```hcl
output "output_name" {
  description = "What this output shows"
  value       = resource.resource_name.attribute
}
```

### How to Use Output Variables

**Define in output.tf**
```hcl
# Output a resource attribute
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.demo.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.demo.arn
}

# Output an input variable (to confirm what was used)
output "environment" {
  description = "Environment from input variable"
  value       = var.environment
}

# Output a local variable (to see computed values)
output "tags" {
  description = "Tags from local variable"
  value       = local.common_tags
}
```

### Viewing Outputs

After running `terraform apply`, you can view outputs:

```bash
terraform output                    # Show all outputs
terraform output bucket_name        # Show specific output
terraform output -json              # Show all outputs in JSON format
```

**Example output:**
```
bucket_arn = "arn:aws:s3:::demo-terraform-demo-bucket-abc123"
bucket_name = "demo-terraform-demo-bucket-abc123"
environment = "demo"
tags = {
  "Environment" = "demo"
  "Owner" = "DevOps-Team"
  "Project" = "Terraform-Demo"
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

## 🧪 Practical Examples

### Example 1: Testing Different Input Values

```bash
# Test with defaults (temporarily hide terraform.tfvars)
mv terraform.tfvars terraform.tfvars.backup
terraform plan
# Shows: Environment = "staging", bucket will be "staging-my-terraform-bucket-xxxxx"

# Test with terraform.tfvars
mv terraform.tfvars.backup terraform.tfvars
terraform plan  
# Shows: Environment = "demo", bucket will be "demo-terraform-demo-bucket-xxxxx"

# Test with command line override
terraform plan -var="environment=test" -var="bucket_name=my-test-bucket"
# Shows: Environment = "test", bucket will be "test-my-test-bucket-xxxxx"
```

### Example 2: Viewing All Variable Types in Action

```bash
# Apply the configuration
terraform apply -auto-approve

# See all outputs (shows output variables)
terraform output
# bucket_arn = "arn:aws:s3:::demo-terraform-demo-bucket-abc123"
# bucket_name = "demo-terraform-demo-bucket-abc123"  
# environment = "demo"                                # (input variable)
# tags = {                                           # (local variable)
#   "Environment" = "demo"
#   "Owner" = "DevOps-Team"  
#   "Project" = "Terraform-Demo"
# }

# See how local variables computed the bucket name
echo "Input: environment = $(terraform output -raw environment)"
echo "Input: bucket_name = terraform-demo-bucket (from tfvars)"  
echo "Local: full_bucket_name = $(terraform output -raw bucket_name)"
echo "Random suffix was added by local variable!"
```

### Example 3: Variable Precedence in Action

```bash
# Start with terraform.tfvars (environment = "demo")
terraform plan | grep Environment
# Shows: "Environment" = "demo"

# Override with environment variable
export TF_VAR_environment="from-env-var"
terraform plan | grep Environment  
# Shows: "Environment" = "from-env-var"

# Override with command line (highest precedence)
terraform plan -var="environment=from-command-line" | grep Environment
# Shows: "Environment" = "from-command-line"

# Clean up
unset TF_VAR_environment
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
