# Day 8 Notes: AWS Terraform Meta Arguments
## 30 Days of AWS Terraform Challenge

---

## 🎯 What are Meta Arguments?

**Meta arguments** = Terraform-provided arguments (not AWS provider)  
- Simplify common logic **without external scripts**  
- Available in all resources  

**Covered in this video:**
1. `count`  
2. `for_each`  
3. `depends_on`  

*(Lifecycle rules → next video)*  

---

## 1. `count` Meta Argument

**Creates multiple identical resources from a LIST**  

### Syntax
```hcl
resource "aws_s3_bucket" "example" {
  count = 2                    # Creates 2 resources
  bucket = var.names[count.index]  # 0, 1, 2...
}
```

### Key Points
- **`count.index`** starts at **0**  
- Works **only with lists** (not sets/maps)  
- Creates resources: `example[0]`, `example[1]`  

### Variable Example
```hcl
variable "bucket_names" {
  type    = list(string)
  default = ["bucket-01", "bucket-02"]
}
```

**Result:** 2 buckets from 1 resource block  

---

## 2. `for_each` Meta Argument

**Iterates over SETS or MAPS** (more flexible than `count`)  

### Set Example
```hcl
variable "bucket_name_set" {
  type    = set(string)
  default = ["bucket-09", "bucket-10"]
}

resource "aws_s3_bucket" "example" {
  for_each = var.bucket_name_set      # Auto-iterates set
  bucket   = each.value               # Current element
  tags     = var.tags
}
```

### Key Points
- **No indexing needed**  
- **Order doesn't matter** (sets are unordered)  
- Creates: `example["bucket-09"]`, `example["bucket-10"]`  

### Map Example
```hcl
variable "bucket_map" {
  type = map(string)
  default = {
    "prod" = "prod-bucket-01"
    "dev"  = "dev-bucket-01"
  }
}

resource "aws_s3_bucket" "example" {
  for_each = var.bucket_map
  bucket   = each.value     # "prod-bucket-01", "dev-bucket-01"
  # each.key  = "prod", "dev"
}
```

**`each.key` vs `each.value`:**
| Data Type | `each.key` | `each.value` |
|-----------|------------|--------------|
| **Set**   | Same as value   | Element |
| **Map**   | Key ("prod")   | Value ("prod-bucket-01")   |

---

## 3. `depends_on` Meta Argument

**Explicitly controls resource creation ORDER**  

### Syntax
```hcl
resource "aws_s3_bucket" "bucket_two" {
  for_each = var.bucket_name_set
  
  bucket = each.value
  
  depends_on = [aws_s3_bucket.bucket_one]  # WAITS for bucket_one
}
```

### Why Needed?
```
❌ WITHOUT depends_on (random order):
bucket_one[0] → bucket_two["bucket-09"] → bucket_one[1]  

✅ WITH depends_on (controlled order):
bucket_one[0] ✓ → bucket_one[1] ✓ → bucket_two["bucket-09"] ✓ → bucket_two["bucket-10"] ✓  
```

### Terraform Defaults
- **Multiple files:** Alphabetical order  
- **Single file:** No guaranteed order  
- **Implicit dependencies:** Via references (covered later)

---

## 📊 Quick Comparison

| Feature | `count` | `for_each` | `depends_on` |
|---------|---------|------------|--------------|
| **Data Type** | List   | Set/Map   | Any   |
| **Indexing** | `count.index`   | `each.key/value`   | N/A |
| **Order** | Sequential   | Unordered   | Enforced   |
| **Resource Names** | `resource[0]`, `resource[1]` | `resource["key"]`   | N/A |

---

## ⚠️ Gotchas & Tips

🔸 **`count.index` always starts at 0**  
🔸 **Sets → `for_each` only** (no `count.index`)  
🔸 **`for_each` on lists?** Convert to set: `toset(var.list)` 
🔸 **Resource references:** `aws_s3_bucket.bucket_one` (type.name)  
🔸 **Check order in `terraform apply`** (not just plan)  





