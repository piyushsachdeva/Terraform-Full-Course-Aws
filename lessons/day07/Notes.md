
# Day 7 - AWS Terraform Type Constraints Explained 

## Overview
This folder demonstrates **Terraform type constraints** through practical AWS examples. Learn primitive and complex data types with EC2 instances and security groups.   

## Learning Objectives

Master these **Terraform variable types**:
- **Primitive**: `string`, `number`, `bool`   
- **Complex**: `list`, `set`, `map`, `tuple`, `object`  
- **Special**: `null`, `any`  

---

## Quick Reference: Type Constraints

| Type | Syntax | Example | Access Method |
|------|--------|---------|---------------|
| **string** | `type = string` | `"us-east-1"` | `var.region`   |
| **number** | `type = number` | `1` | `var.instance_count`   |
| **bool** | `type = bool` | `true` | `var.monitoring_enabled`   |
| **list** | `type = list(string)` | `["t2.micro", "t2.small"]` | `var.list[0]`   |
| **set** | `type = set(string)` | `{"us-east-1", "us-west-2"}` | `tolist(var.set)[0]`   |
| **map** | `type = map(string)` | `{Name = "dev-instance"}` | `var.map.Name`   |
| **tuple** | `type = tuple([number, string])` | `[443, "TCP"]` | `var.tuple[0]`   |
| **object** | `type = object({...})` | `{region = "us-east-1"}` | `var.object.region`   |

---

## Prerequisites

- Complete **Day 0-6** of 30 Days AWS Terraform challenge  
- AWS credentials configured
- Terraform installed
- VS Code with Terraform extension

---

## Project Structure

```
day07/
├── main.tf              # Core infrastructure (EC2 + Security Groups)
├── variables.tf         # All type constraint examples
├── terraform.tfvars     # Variable values (optional)
├── backend.tf          # Remote backend configuration
├── task.md             # Hands-on exercises
└── README.md           # This file
```

---

## Quick Start

1. **Navigate to folder**:
   ```bash
   cd day07
   ```

2. **Initialize Terraform**:
   ```bash
   tf init
   ```

3. **Review plan** (see type validation):
   ```bash
   tf plan
   ```

4. **Deploy**:
   ```bash
   tf apply
   ```

5. **Destroy** (cleanup):
   ```bash
   tf destroy
   ```

---

## Key Examples Demonstrated

### 1. Primitive Types
```
# variables.tf
variable "instance_count" { type = number }
variable "region" { type = string }
variable "monitoring_enabled" { type = bool }
```

### 2. List & Set
```
variable "cidr_blocks" { type = list(string) }
variable "allowed_regions" { type = set(string) }
```

### 3. Map & Object
```
variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Name = "dev-instance"
  }
}

variable "config" {
  type = object({
    region = string
    monitoring = bool
  })
}
```

---

## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid index` | Set accessed directly | Use `tolist(var.set)[0]`   |
| `Variables not allowed` | Variable in variable default | Use locals or hardcode   |
| `Type mismatch` | Wrong type assigned | Check `tf plan` early   |
| `Duplicates in set` | Set contains duplicates | Sets auto-remove duplicates   |

---

## Hands-On Task

**Complete `task.md`**:
1. Create all 8 type constraint examples
2. Test with `tf plan`
3. Modify values and observe validation
4. Submit your work (Day 7 challenge)  

---

## Best Practices

🔑 **Always specify `type`** - Catches errors during planning  
🔑 **Use `default` values** - Makes code self-contained
🔑 **Group related config** - Use `object` for resource metadata  
🔑 **Plan before apply** - Validates all types instantly


