# Demo Guide - Day 10 Examples

This guide shows how to demonstrate each example one at a time by commenting/uncommenting code blocks.

## Initial Setup

```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day10/code
terraform init
```

---

## Demo 1: Conditional Expression

### Current State
✅ **Example 1 is ACTIVE** (uncommented in `main.tf`)  
❌ Example 2 is commented out  
❌ Example 3 is commented out

### Steps

1. **Show the code** in `main.tf`:
   ```hcl
   instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"
   ```

2. **Test with dev environment**:
   ```bash
   terraform plan -var-file="dev.tfvars"
   ```
   Expected: Shows `t2.micro` instance type

3. **Test with prod environment**:
   ```bash
   terraform plan -var-file="prod.tfvars"
   ```
   Expected: Shows `t3.large` instance type

4. **Apply with dev**:
   ```bash
   terraform apply -var-file="dev.tfvars" -auto-approve
   ```

5. **View output**:
   ```bash
   terraform output conditional_instance_type
   ```
   Shows: `"t2.micro"`

6. **Change to prod and see the difference**:
   ```bash
   terraform apply -var-file="prod.tfvars" -auto-approve
   terraform output conditional_instance_type
   ```
   Shows: `"t3.large"`

7. **Cleanup**:
   ```bash
   terraform destroy -var-file="prod.tfvars" -auto-approve
   ```

---

## Demo 2: Dynamic Block

### Preparation

1. **Comment out Example 1** in `main.tf`:
   - Add `#` before each line of `resource "aws_instance" "conditional_example"`
   - Comment out its outputs in `outputs.tf`

2. **Uncomment Example 2** in `main.tf`:
   - Remove `#` from `resource "aws_security_group" "dynamic_sg"`
   - Uncomment its outputs in `outputs.tf`

### Steps

1. **Show the dynamic block** in `main.tf`:
   ```hcl
   dynamic "ingress" {
     for_each = var.ingress_rules
     content {
       from_port = ingress.value.from_port
       # ...
     }
   }
   ```

2. **Show the variable** in `terraform.tfvars`:
   ```hcl
   ingress_rules = [
     { from_port = 80, ... },
     { from_port = 443, ... }
   ]
   ```

3. **Plan and see how many rules will be created**:
   ```bash
   terraform plan
   ```

4. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

5. **View outputs**:
   ```bash
   terraform output
   ```

6. **Add a new rule** in `terraform.tfvars`:
   ```hcl
   ingress_rules = [
     # ... existing rules ...
     {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["10.0.0.0/8"]
       description = "SSH"
     }
   ]
   ```

7. **Apply again to see dynamic addition**:
   ```bash
   terraform apply -auto-approve
   ```

8. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## Demo 3: Splat Expression

### Preparation

1. **Comment out Example 2** in `main.tf` and `outputs.tf`

2. **Uncomment Example 3** in `main.tf`:
   - Remove `#` from `resource "aws_instance" "splat_example"`
   - Remove `#` from the `locals` block
   - Uncomment outputs in `outputs.tf`

### Steps

1. **Show the splat syntax** in `main.tf`:
   ```hcl
   all_instance_ids = aws_instance.splat_example[*].id
   all_private_ips = aws_instance.splat_example[*].private_ip
   ```

2. **Explain**: Instead of a loop, `[*]` extracts all values at once

3. **Set instance count** in `terraform.tfvars`:
   ```hcl
   instance_count = 3
   ```

4. **Plan and see 3 instances will be created**:
   ```bash
   terraform plan
   ```

5. **Apply**:
   ```bash
   terraform apply -auto-approve
   ```

6. **View splat expression results**:
   ```bash
   terraform output all_instance_ids
   terraform output all_private_ips
   ```
   Shows: Arrays of all IDs and IPs

7. **Test in console** (interactive):
   ```bash
   terraform console
   ```
   Try:
   ```hcl
   aws_instance.splat_example[*].id
   aws_instance.splat_example[*].private_ip
   aws_instance.splat_example[*].tags.Name
   ```

8. **Cleanup**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## Quick Reference: Comment/Uncomment Patterns

### To Switch Examples:

**Activate Example 1 Only:**
```
main.tf: ✅ Example 1 uncommented, ❌ Example 2 & 3 commented
outputs.tf: ✅ Example 1 outputs uncommented, ❌ Example 2 & 3 commented
```

**Activate Example 2 Only:**
```
main.tf: ❌ Example 1 commented, ✅ Example 2 uncommented, ❌ Example 3 commented
outputs.tf: ❌ Example 1 commented, ✅ Example 2 outputs uncommented, ❌ Example 3 commented
```

**Activate Example 3 Only:**
```
main.tf: ❌ Example 1 & 2 commented, ✅ Example 3 uncommented
outputs.tf: ❌ Example 1 & 2 commented, ✅ Example 3 outputs uncommented
```

---

## Tips for Smooth Demo

1. **Use separate terminal windows** for editing and running commands
2. **Show outputs** after each apply to demonstrate the concept
3. **Use terraform console** for interactive exploration (especially for splat)
4. **Explain before applying** what will happen
5. **Always cleanup** before switching examples

---

## Troubleshooting

**Error: Reference to undeclared resource**
- Make sure you uncommented both the resource AND its outputs

**Error: Output refers to sensitive values**
- This is normal for some AWS attributes, just note it

**Want to run all examples together?**
- Uncomment all three examples at once
- Uncomment all outputs
- Run `terraform apply`
