# Terraform Functions Demo Guide - Day 11-12

## Overview
This guide provides step-by-step instructions for demonstrating Terraform built-in functions through 12 hands-on assignments. Each assignment focuses on specific functions and can be tested independently by commenting/uncommenting code blocks.

---

## Initial Setup

```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day11-12

# Initialize Terraform (comment out backend in backend.tf for local testing)
terraform init

# Test basic functions in console
terraform console
```

---

## Console Practice

Before starting assignments, practice these basic functions in `terraform console`:

```hcl
# String functions
lower("HELLO WORLD")              # "hello world"
upper("hello world")              # "HELLO WORLD"
replace("hello world", " ", "-") # "hello-world"
substr("hello", 0, 3)             # "hel"
trim("  hello  ")                 # "hello"

# Numeric functions  
max(5, 12, 9)                     # 12
min(5, 12, 9)                     # 5
abs(-42)                          # 42

# Collection functions
length([1, 2, 3])                 # 3
concat([1, 2], [3, 4])            # [1, 2, 3, 4]
merge({a=1}, {b=2})               # {a=1, b=2}

# Type conversion
toset(["a", "b", "a"])           # toset(["a", "b"])
tonumber("42")                    # 42

# Date/time
timestamp()                       # current timestamp
formatdate("DD-MM-YYYY", timestamp())

# Exit console
exit
```

---

## 📋 Assignment 1: Project Naming Convention

**Functions:** `lower()`, `replace()`

### Current State
✅ **Active by default** (uncommented in main.tf)

### What It Does
Transforms "Project ALPHA Resource" → "project-alpha-resource"

### Demo Steps

1. **Show the input** in `variables.tf`:
   ```hcl
   variable "project_name" {
     default = "Project ALPHA Resource"
   }
   ```

2. **Show the transformation** in `main.tf`:
   ```hcl
   locals {
     formatted_project_name = lower(replace(var.project_name, " ", "-"))
   }
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```
   Point out the formatted name in the plan.

4. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

5. **View outputs**:
   ```bash
   terraform output formatted_project_name
   terraform output resource_group_name
   ```

6. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   local.formatted_project_name
   var.project_name
   exit
   ```

7. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 2: Resource Tagging

**Function:** `merge()`

### Preparation
1. Comment out Assignment 1 resources in `main.tf`
2. Uncomment Assignment 2 blocks in `main.tf`  
3. Uncomment Assignment 2 outputs in `outputs.tf`

### What It Does
Combines default company tags with environment-specific tags.

### Demo Steps

1. **Show the tag variables** in `variables.tf`:
   ```hcl
   variable "default_tags" {
     default = {
       company    = "TechCorp"
       managed_by = "terraform"
     }
   }
   
   variable "environment_tags" {
     default = {
       environment = "production"
       cost_center = "cc-123"
     }
   }
   ```

2. **Show the merge** in `main.tf`:
   ```hcl
   locals {
     merged_tags = merge(var.default_tags, var.environment_tags)
   }
   ```

3. **Plan and Apply**:
   ```bash
   terraform plan
   terraform apply -auto-approve
   ```

4. **View merged tags**:
   ```bash
   terraform output merged_tags
   terraform output vpc_tags
   ```

5. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   merge(var.default_tags, var.environment_tags)
   local.merged_tags
   exit
   ```

6. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 3: S3 Bucket Naming

**Functions:** `substr()`, `replace()`, `lower()`

### Preparation
1. Comment out Assignment 2
2. Uncomment Assignment 3 in `main.tf` and `outputs.tf`

### What It Does
Transforms invalid S3 name to valid format:
- Input: "ProjectAlphaStorageBucket with CAPS and spaces!!!"
- Output: "projectalphastoragebucket" (max 63 chars, lowercase, no spaces/special chars)

### Demo Steps

1. **Show the challenge** in `variables.tf`:
   ```hcl
   variable "bucket_name" {
     default = "ProjectAlphaStorageBucket with CAPS and spaces!!!"
   }
   ```

2. **Show the transformation** in `main.tf`:
   ```hcl
   locals {
     formatted_bucket_name = replace(
       replace(
         lower(substr(var.bucket_name, 0, 63)),
         " ", ""
       ),
       "!", ""
     )
   }
   ```

3. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

4. **View transformation**:
   ```bash
   terraform output original_bucket_name
   terraform output formatted_bucket_name
   ```

5. **Verify in AWS Console** or CLI:
   ```bash
   aws s3 ls | grep project
   ```

6. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 4: Security Group Port Configuration

**Functions:** `split()`, `join()`, `for` expression

### Preparation
1. Comment out Assignment 3
2. Uncomment Assignment 2 (VPC dependency)
3. Uncomment Assignment 4 in `main.tf` and `outputs.tf`

### What It Does
- Input: "80,443,8080,3306"
- Creates security group rules for each port
- Output format: "port-80-port-443-port-8080-port-3306"

### Demo Steps

1. **Show the port list** in `variables.tf`:
   ```hcl
   variable "allowed_ports" {
     default = "80,443,8080,3306"
   }
   ```

2. **Show the transformation** in `main.tf`:
   ```hcl
   locals {
     port_list = split(",", var.allowed_ports)
     
     sg_rules = [for port in local.port_list : {
       name = "port-${port}"
       port = port
       description = "Allow traffic on port ${port}"
     }]
     
     formatted_ports = join("-", [for port in local.port_list : "port-${port}"])
   }
   ```

3. **Test in console first**:
   ```bash
   terraform console
   ```
   ```hcl
   split(",", "80,443,8080,3306")
   local.port_list
   local.sg_rules
   local.formatted_ports
   exit
   ```

4. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

5. **View outputs**:
   ```bash
   terraform output port_list
   terraform output security_group_rules
   terraform output formatted_ports
   terraform output security_group_id
   ```

6. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 5: Environment Configuration Lookup

**Function:** `lookup()`

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 5 in `main.tf` and `outputs.tf`

### What It Does
Selects instance size based on environment using lookup with fallback.

### Demo Steps

1. **Show the configuration map** in `variables.tf`:
   ```hcl
   variable "instance_sizes" {
     default = {
       dev     = "t2.micro"
       staging = "t3.small"
       prod    = "t3.large"
     }
   }
   ```

2. **Show the lookup** in `main.tf`:
   ```hcl
   locals {
     instance_size = lookup(var.instance_sizes, var.environment, "t2.micro")
   }
   ```

3. **Test different environments**:
   ```bash
   # Dev environment
   terraform plan -var="environment=dev"
   
   # Prod environment
   terraform plan -var="environment=prod"
   
   # Invalid environment (uses fallback)
   terraform plan -var="environment=test"  # Will fail validation
   ```

4. **Apply with dev**:
   ```bash
   terraform apply -var="environment=dev" -auto-approve
   ```

5. **View result**:
   ```bash
   terraform output instance_size
   terraform output instance_id
   ```

6. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   lookup(var.instance_sizes, "dev", "t2.micro")
   lookup(var.instance_sizes, "prod", "t2.micro")
   lookup(var.instance_sizes, "invalid", "t2.micro")  # Returns fallback
   exit
   ```

7. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 6: Instance Type Validation

**Functions:** `length()`, `can()`, `regex()`

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 5 (for AMI data source)
3. Uncomment Assignment 6 in `main.tf` and `outputs.tf`

### What It Does
Validates instance type using multiple rules:
- Length between 2 and 20 characters
- Must start with "t2" or "t3"

### Demo Steps

1. **Show validations** in `variables.tf`:
   ```hcl
   variable "instance_type" {
     default = "t2.micro"
     
     validation {
       condition     = length(var.instance_type) >= 2 && length(var.instance_type) <= 20
       error_message = "Instance type must be between 2 and 20 characters"
     }
     
     validation {
       condition     = can(regex("^t[2-3]\\.", var.instance_type))
       error_message = "Instance type must start with t2 or t3"
     }
   }
   ```

2. **Test valid instance type**:
   ```bash
   terraform plan -var="instance_type=t2.micro"
   ```

3. **Test invalid length**:
   ```bash
   terraform plan -var="instance_type=t"
   # Shows error: "Instance type must be between 2 and 20 characters"
   ```

4. **Test invalid pattern**:
   ```bash
   terraform plan -var="instance_type=m5.large"
   # Shows error: "Instance type must start with t2 or t3"
   ```

5. **Apply with valid type**:
   ```bash
   terraform apply -var="instance_type=t3.small" -auto-approve
   ```

6. **View output**:
   ```bash
   terraform output validated_instance_type
   ```

7. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 7: Backup Configuration

**Functions:** `endswith()`, `sensitive` attribute

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 7 in `main.tf` and `outputs.tf`

### What It Does
- Validates backup name ends with "_backup"
- Handles sensitive credentials properly

### Demo Steps

1. **Show validations** in `variables.tf`:
   ```hcl
   variable "backup_name" {
     default = "daily_backup"
     
     validation {
       condition     = endswith(var.backup_name, "_backup")
       error_message = "Backup name must end with '_backup'"
     }
   }
   
   variable "credential" {
     default   = "xyz123"
     sensitive = true
   }
   ```

2. **Test valid backup name**:
   ```bash
   terraform plan -var="backup_name=daily_backup"
   ```

3. **Test invalid backup name**:
   ```bash
   terraform plan -var="backup_name=daily"
   # Shows error: "Backup name must end with '_backup'"
   ```

4. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

5. **View outputs (note sensitive handling)**:
   ```bash
   terraform output backup_name
   terraform output backup_credential  # Shows <sensitive>
   ```

6. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   endswith("daily_backup", "_backup")    # true
   endswith("daily", "_backup")           # false
   exit
   ```

7. **Cleanup** (no resources created):
   ```bash
   # Nothing to destroy
   ```

---

## 📋 Assignment 9: Resource Location Management

**Functions:** `toset()`, `concat()`

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 9 in `main.tf` and `outputs.tf`

### What It Does
Combines location lists and removes duplicates.

### Demo Steps

1. **Show the lists** in `variables.tf`:
   ```hcl
   variable "user_locations" {
     default = ["us-east-1", "us-west-2", "us-east-1"]  # Has duplicate
   }
   
   variable "default_locations" {
     default = ["us-west-1"]
   }
   ```

2. **Show the combination** in `main.tf`:
   ```hcl
   locals {
     all_locations    = concat(var.user_locations, var.default_locations)
     unique_locations = toset(local.all_locations)
   }
   ```

3. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   concat(["us-east-1", "us-west-2"], ["us-west-1"])
   toset(["us-east-1", "us-west-2", "us-east-1"])
   local.all_locations
   local.unique_locations
   exit
   ```

4. **Plan** (no resources):
   ```bash
   terraform plan
   ```

5. **View outputs**:
   ```bash
   terraform output all_locations       # Shows duplicates
   terraform output unique_locations    # Duplicates removed
   terraform output location_count
   ```

---

## 📋 Assignment 10: Cost Calculation

**Functions:** `abs()`, `max()`, `sum()`, `for` expression

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 10 in `main.tf` and `outputs.tf`

### What It Does
Processes monthly costs:
- Converts negative values (credits) to positive
- Finds maximum cost
- Calculates totals and averages

### Demo Steps

1. **Show cost data** in `variables.tf`:
   ```hcl
   variable "monthly_costs" {
     default = [-50, 100, 75, 200]  # -50 is a credit
   }
   ```

2. **Show calculations** in `main.tf`:
   ```hcl
   locals {
     positive_costs = [for cost in var.monthly_costs : abs(cost)]
     max_cost       = max(local.positive_costs...)
     total_cost     = sum(local.positive_costs)
     avg_cost       = local.total_cost / length(local.positive_costs)
   }
   ```

3. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   abs(-50)                              # 50
   [for cost in [-50, 100, 75, 200] : abs(cost)]
   max(50, 100, 75, 200)                 # 200
   exit
   ```

4. **View outputs**:
   ```bash
   terraform plan
   terraform output original_costs
   terraform output positive_costs
   terraform output max_cost
   terraform output total_cost
   terraform output average_cost
   ```

---

## 📋 Assignment 11: Timestamp Management

**Functions:** `timestamp()`, `formatdate()`

### Preparation
1. Comment out previous assignments
2. Uncomment Assignment 11 in `main.tf` and `outputs.tf`

### What It Does
Generates formatted timestamps for different purposes:
- Resource names: YYYYMMDD
- Tags: DD-MM-YYYY

### Demo Steps

1. **Show the formatting** in `main.tf`:
   ```hcl
   locals {
     current_timestamp    = timestamp()
     resource_date_suffix = formatdate("YYYYMMDD", local.current_timestamp)
     tag_date_format      = formatdate("DD-MM-YYYY", local.current_timestamp)
     timestamped_name     = "backup-${local.resource_date_suffix}"
   }
   ```

2. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   timestamp()
   formatdate("YYYYMMDD", timestamp())
   formatdate("DD-MM-YYYY", timestamp())
   formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
   exit
   ```

3. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

4. **View outputs**:
   ```bash
   terraform output current_timestamp
   terraform output resource_date_suffix
   terraform output tag_date_format
   terraform output timestamped_bucket_name
   ```

5. **Note**: Running terraform again will change timestamps (showing dynamic nature)

6. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## 📋 Assignment 12: File Content Handling

**Functions:** `file()`, `fileexists()`, `jsondecode()`, `jsonencode()`, `sensitive`

### Preparation
1. Comment out previous assignments
2. Create a test config file
3. Uncomment Assignment 12 in `main.tf` and `outputs.tf`

### What It Does
Securely reads and stores JSON configuration in AWS Secrets Manager.

### Demo Steps

1. **Create config.json**:
   ```bash
   cat > config.json << 'EOF'
   {
     "database": {
       "host": "db.example.com",
       "port": 5432,
       "username": "admin",
       "password": "super-secret"
     },
     "api": {
       "endpoint": "https://api.example.com",
       "timeout": 30
     }
   }
   EOF
   ```

2. **Show the file handling** in `main.tf`:
   ```hcl
   locals {
     config_file_exists = fileexists("./config.json")
     config_data        = local.config_file_exists ? jsondecode(file("./config.json")) : {}
   }
   ```

3. **Test in console**:
   ```bash
   terraform console
   ```
   ```hcl
   fileexists("./config.json")
   file("./config.json")
   jsondecode(file("./config.json"))
   exit
   ```

4. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

5. **View outputs**:
   ```bash
   terraform output config_file_exists
   terraform output config_data          # Non-sensitive parts only
   terraform output secret_arn
   ```

6. **Verify in AWS Secrets Manager**:
   ```bash
   aws secretsmanager list-secrets --query 'SecretList[?contains(Name, `app-configuration`)].Name'
   ```

7. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   rm config.json
   ```

---

## 🎯 Quick Reference: Comment/Uncomment Pattern

### Single Assignment Testing
```
main.tf:     ✅ Assignment X uncommented, ❌ All others commented
outputs.tf:  ✅ Assignment X outputs uncommented, ❌ All others commented
```

### With Dependencies
Some assignments require others:
- Assignment 4 requires Assignment 2 (VPC)
- Assignment 6 requires Assignment 5 (AMI data source)

---

## 📊 Function Categories Summary

| Category | Functions | Assignments |
|----------|-----------|-------------|
| **String** | lower, upper, replace, substr, trim | 1, 3 |
| **Collection** | merge, concat, split, join | 2, 4, 9 |
| **Conversion** | toset, tonumber, jsondecode | 9, 12 |
| **Numeric** | abs, max, sum | 10 |
| **Validation** | length, can, regex, endswith | 6, 7 |
| **Lookup** | lookup | 5 |
| **File** | file, fileexists, dirname | 8, 12 |
| **Date/Time** | timestamp, formatdate | 11 |
| **Sensitive** | sensitive attribute | 7, 12 |

---

## 💡 Tips for Smooth Demo

1. **Use terraform console** extensively to show function behavior
2. **Show before/after** for transformations
3. **Explain validation errors** when they occur
4. **Point out outputs** that demonstrate the functions
5. **Keep only one assignment active** at a time for clarity
6. **Use `-auto-approve`** for faster demos (after showing plan)
7. **Have config.json** pre-created for Assignment 12

---

## ⚠️ Common Issues

**Issue:** Backend configuration error  
**Solution:** Comment out backend block in `backend.tf` for local testing

**Issue:** Resource already exists  
**Solution:** Run `terraform destroy` before switching assignments

**Issue:** Validation errors  
**Solution:** These are expected! Show students the error messages

**Issue:** Timestamp changes on every run  
**Solution:** This is expected behavior for `timestamp()` function

---

## 🚀 Next Steps

After completing these assignments, students should:
1. Understand when to use each function type
2. Be comfortable reading Terraform documentation
3. Know how to test functions in terraform console
4. Be able to combine multiple functions
5. Understand data validation patterns

Proceed to **Day 13** for more advanced Terraform concepts!
