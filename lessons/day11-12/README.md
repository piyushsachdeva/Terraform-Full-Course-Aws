# Terraform Functions Learning Guide - AWS Edition (Day 11-12)

## 📚 Overview

Welcome to the Terraform Functions comprehensive learning guide! This two-day module covers Terraform's built-in functions through 12 hands-on assignments. Each assignment focuses on specific functions and real-world use cases.


---

## 🎯 Learning Objectives

By the end of this module, you will:
1. Master Terraform's built-in functions across all categories
2. Understand when and how to use each function type
3. Know how to combine multiple functions effectively
4. Be proficient with the Terraform console for testing
5. Implement proper validation and error handling
6. Handle sensitive data securely
7. Create dynamic, reusable configurations

---

## Console Commands

Practice these fundamental commands in `terraform console` before starting the assignments:

```hcl
# Basic String Manipulation
lower("HELLO WORLD")
max(5, 12, 9)
trim("  hello  ", " ")
chomp("hello\n")
reverse(["a", "b", "c"])
```

## 📋 Assignments Overview

| # | Assignment | Functions | Difficulty | AWS Resources |
|---|------------|-----------|------------|---------------|
| 1 | Project Naming | `lower`, `replace` | ⭐ | Resource Group |
| 2 | Resource Tagging | `merge` | ⭐ | VPC |
| 3 | S3 Bucket Naming | `substr`, `replace`, `lower` | ⭐⭐ | S3 Bucket |
| 4 | Security Group Ports | `split`, `join`, `for` | ⭐⭐ | Security Group |
| 5 | Environment Lookup | `lookup` | ⭐⭐ | EC2 Instance |
| 6 | Instance Validation | `length`, `can`, `regex` | ⭐⭐⭐ | EC2 Instance |
| 7 | Backup Configuration | `endswith`, `sensitive` | ⭐⭐ | None |
| 8 | File Path Processing | `fileexists`, `dirname` | ⭐⭐ | None |
| 9 | Location Management | `toset`, `concat` | ⭐ | None |
| 10 | Cost Calculation | `abs`, `max`, `sum` | ⭐⭐ | None |
| 11 | Timestamp Management | `timestamp`, `formatdate` | ⭐⭐ | S3 Bucket |
| 12 | File Content Handling | `file`, `jsondecode` | ⭐⭐⭐ | Secrets Manager |

---

## 🚀 Quick Start

```bash
# Navigate to directory
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day11-12

# Initialize
terraform init

# Start with Assignment 1 (already uncommented)
terraform plan
terraform apply -auto-approve

# View outputs
terraform output

# Cleanup
terraform destroy -auto-approve
```

---

## 📖 Function Categories

### String Functions
`lower()`, `upper()`, `replace()`, `substr()`, `trim()`, `split()`, `join()`, `chomp()`

### Numeric Functions
`abs()`, `max()`, `min()`, `ceil()`, `floor()`, `sum()`
 
### Collection Functions
`length()`, `concat()`, `merge()`, `reverse()`, `toset()`, `tolist()`

### Type Conversion
`tonumber()`, `tostring()`, `tobool()`, `toset()`, `tolist()`

### File Functions
`file()`, `fileexists()`, `dirname()`, `basename()`

### Date/Time Functions
`timestamp()`, `formatdate()`, `timeadd()`art

### Validation Functions
`can()`, `regex()`, `contains()`, `startswith()`, `endswith()`

### Lookup Functions
`lookup()`, `element()`, `index()`

---

## 📁 Files

- `README.md` - This overview
- `DEMO_GUIDE.md` - **Step-by-step demo instructions**
- `provider.tf` - AWS provider setup
- `backend.tf` - S3 backend (optional)
- `variables.tf` - All assignment variables
- `main.tf` - All 12 assignments (commented structure)
- `outputs.tf` - Assignment outputs (commented)


---

## ✅ Assignment Summary

### Assignment 1: Project Naming ⭐
Transform "Project ALPHA Resource" → "project-alpha-resource"

**Functions:** `lower()`, `replace()`  
**Status:** ✅ Active by default

### Assignment 2: Resource Tagging ⭐
Merge default and environment tags

**Function:** `merge()`

### Assignment 3: S3 Bucket Naming ⭐⭐
Sanitize bucket names for AWS compliance

**Functions:** `substr()`, `replace()`, `lower()`

### Assignment 4: Security Group Ports ⭐⭐
Transform "80,443,8080" into security group rules

**Functions:** `split()`, `join()`, `for`

### Assignment 5: Environment Lookup ⭐⭐
Select instance size by environment

**Function:** `lookup()`

### Assignment 6: Instance Validation ⭐⭐⭐
Validate instance type format

**Functions:** `length()`, `can()`, `regex()`

### Assignment 7: Backup Configuration ⭐⭐
Validate names and handle sensitive data

**Functions:** `endswith()`, `sensitive`

### Assignment 8: File Path Processing ⭐⭐
Check file existence and extract paths

**Functions:** `fileexists()`, `dirname()`

### Assignment 9: Location Management ⭐
Combine regions and remove duplicates

**Functions:** `toset()`, `concat()`

### Assignment 10: Cost Calculation ⭐⭐
Process costs with credits

**Functions:** `abs()`, `max()`, `sum()`

### Assignment 11: Timestamp Management ⭐⭐
Format timestamps for resources and tags

**Functions:** `timestamp()`, `formatdate()`

### Assignment 12: File Content Handling ⭐⭐⭐
Read JSON config and store in Secrets Manager

**Functions:** `file()`, `jsondecode()`, `jsonencode()`

---


---

## 📚 Resources

- [Terraform Functions Docs](https://www.terraform.io/language/functions)
- [Terraform Console](https://www.terraform.io/cli/commands/console)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [DEMO_GUIDE.md](DEMO_GUIDE.md) - Complete demo instructions

---

## 🚀 Next Steps

After completing all assignments:
- ✅ Understand all function categories
- ✅ Know when to use each function
- ✅ Comfortable with terraform console
- ✅ Ready for **Day 13**: Terraform Workspaces

---

**Happy Learning! 🎉**
