# Day 5: Variables

## Topics Covered
- Input variables
- Output variables
- Local values
- Variable precedence
- Variable files (tfvars)

## Key Learning Points

### Input Variables
Input variables allow you to parameterize your Terraform configuration, making it reusable across different environments.

### Types of Variables
1. **Input Variables**: Parameters that users can provide
2. **Output Variables**: Values exposed after infrastructure creation
3. **Local Values**: Computed values used within configuration

### Variable Types
- `string` - Text values
- `number` - Numeric values
- `bool` - True/false values
- `list(type)` - Ordered collection
- `set(type)` - Unordered collection of unique values
- `map(type)` - Key-value pairs
- `object({...})` - Complex structured data
- `tuple([...])` - Ordered collection with specific types

### Variable Precedence (highest to lowest)
1. Command-line flags (`-var` or `-var-file`)
2. `*.auto.tfvars` files (alphabetical order)
3. `terraform.tfvars` file
4. Environment variables (`TF_VAR_name`)
5. Variable defaults

### Local Values
Local values assign a name to an expression, allowing you to reuse it multiple times without repeating the expression.

## Tasks for Practice

### Task 1: Update Previous Configuration with Variables
Using the files created in Day 4, update them to use variables:

1. **Add input variable named "environment"**
   - Set default value to "staging"
   - Use in resource naming and tagging

2. **Create terraform.tfvars file**
   - Set environment value to "demo"
   - Add other relevant variables

3. **Test variable precedence**
   - Pass variables via tfvars file
   - Override via environment variables
   - Override via command line

### Variable Configuration Examples

#### variables.tf
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

#### terraform.tfvars
```hcl
environment  = "demo"
project_name = "aws-terraform-course"
region       = "us-east-1"
vpc_cidr     = "10.0.0.0/16"

tags = {
  Project     = "TerraformLearning"
  Environment = "demo"
  Owner       = "DevOps-Team"
}
```

#### locals.tf
```hcl
locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  })

  # Resource naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # VPC configuration
  vpc_name = "${local.name_prefix}-vpc"
  
  # S3 bucket name (must be globally unique)
  bucket_name = "${local.name_prefix}-terraform-state-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
```

#### outputs.tf
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
```

### Task 2: Variable Precedence Testing

Test different ways to pass variables:

1. **Default values** (in variables.tf)
```bash
terraform plan
```

2. **Via terraform.tfvars**
```bash
terraform plan -var-file="terraform.tfvars"
```

3. **Via environment variables**
```bash
export TF_VAR_environment="production"
terraform plan
```

4. **Via command line**
```bash
terraform plan -var="environment=development"
```

### Task 3: Create Local Variables
Create a local variable with common tags:
- env = dev
- department = engineering  
- stage = alpha
- project = aws-learning

Use the local variable in the tags section of your resources.

### Task 4: Create Output Variables
Create output variables to print:
- VPC ID
- S3 bucket name
- S3 bucket ARN
- Environment name

### Variable Validation
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
  
  validation {
    condition = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

### Sensitive Variables
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}
```

### Commands for Testing
```bash
# Plan with default values
terraform plan

# Plan with specific tfvars file
terraform plan -var-file="production.tfvars"

# Plan with command-line variables
terraform plan -var="environment=test" -var="region=us-west-2"

# Apply with variables
terraform apply -var="environment=demo"

# Show outputs
terraform output

# Show specific output
terraform output vpc_id

# Show sensitive outputs
terraform output -json
```

### Best Practices
1. **Always provide descriptions** for variables
2. **Use meaningful default values** where appropriate
3. **Validate variable inputs** to catch errors early
4. **Group related variables** logically
5. **Use locals for computed values** and complex expressions
6. **Mark sensitive variables** appropriately
7. **Use consistent naming conventions**
8. **Document variable requirements** in README

### Common Patterns
```hcl
# Environment-specific values
variable "instance_types" {
  description = "Instance types by environment"
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

# List of allowed values
variable "allowed_regions" {
  description = "List of allowed AWS regions"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

# Complex object
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool
    tags                 = map(string)
  })
  default = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags                 = {}
  }
}
```

## Next Steps
Proceed to Day 6 to learn about Terraform file structure and organization best practices for maintainable infrastructure code.
