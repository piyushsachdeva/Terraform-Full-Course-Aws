# Day 10: Terraform Dynamic Blocks, Conditional Expressions, and Splat Expressions

## 📚 Topics Covered
- **Conditional Expressions** - Make decisions in your configurations
- **Dynamic Blocks** - Create flexible, repeatable nested blocks
- **Splat Expressions** - Extract values from lists efficiently

---

## 🎯 Learning Objectives

By the end of this lesson, you will:
1. Master conditional expressions for environment-based configurations
2. Use dynamic blocks to eliminate code duplication
3. Apply splat expressions to extract data from multiple resources
4. Understand when to use each expression type
5. Combine multiple expression types for powerful configurations
6. Write cleaner, more maintainable Terraform code

---

## 🔧 Expressions Explained

### 1. Conditional Expressions

**What it does:**  
Evaluates a condition and returns one of two values based on whether the condition is true or false.

**Syntax:**
```hcl
condition ? true_value : false_value
```

**How it works:**
- If `condition` is `true`, returns `true_value`
- If `condition` is `false`, returns `false_value`
- Similar to ternary operators in programming languages

**Use Cases:**
- ✅ Choose instance types based on environment (dev vs prod)
- ✅ Enable/disable monitoring based on configuration
- ✅ Select different AMIs based on region
- ✅ Set different resource counts for environments
- ✅ Apply environment-specific tags

**Benefits:**
- ✅ Single configuration for multiple environments
- ✅ Reduces code duplication
- ✅ Makes environment differences explicit
- ✅ Simplifies configuration management
- ✅ Easy to understand and maintain

**When to use:**
- ✅ Environment-specific configurations
- ✅ Feature flags (enable/disable features)
- ✅ Conditional resource creation
- ✅ Region-specific settings
- ✅ Cost optimization (smaller resources in dev)

**When NOT to use:**
- ❌ Complex logic with many conditions (use locals instead)
- ❌ When separate environment files are clearer
- ❌ When all environments should be identical

---

### 2. Dynamic Blocks

**What it does:**  
Generates multiple nested blocks within a resource based on a collection (list or map). Eliminates the need to repeat similar block configurations.

**Syntax:**
```hcl
dynamic "block_name" {
    for_each = var.collection
    content {
        # Block configuration using each.key and each.value
    }
}
```

**How it works:**
- `for_each` iterates over a list or map
- `content` defines what each block should contain
- Access values using `block_name.value` or `block_name.key`

**Use Cases:**
- ✅ Security group ingress/egress rules
- ✅ Multiple EBS volumes on EC2 instances
- ✅ IAM policy statements
- ✅ Load balancer listeners
- ✅ Route table routes
- ✅ Any repeating nested block structure

**Benefits:**
- ✅ Eliminates repetitive code
- ✅ Easy to add/remove items
- ✅ Configuration through variables
- ✅ Cleaner, more maintainable code
- ✅ Supports complex data structures

**When to use:**
- ✅ Multiple similar nested blocks
- ✅ Variable number of configurations
- ✅ Security group rules
- ✅ Inline policies
- ✅ Any repeating block pattern

**When NOT to use:**
- ❌ Single or few static blocks (overhead not worth it)
- ❌ When it makes code harder to read
- ❌ For top-level resources (use count or for_each instead)

**Best Practices:**
1. Use meaningful iterator names (not just `item`)
2. Keep dynamic blocks simple
3. Document the expected data structure
4. Validate input variables
5. Avoid nesting dynamic blocks too deeply

---

### 3. Splat Expressions

**What it does:**  
Extracts attribute values from all elements in a list in a single, concise expression. The `[*]` operator is the splat operator.

**Syntax:**
```hcl
resource_list[*].attribute_name
```

**How it works:**
- Takes a list of resources/objects
- Extracts specified attribute from each element
- Returns a new list with just those values

**Use Cases:**
- ✅ Get all instance IDs from multiple EC2 instances
- ✅ Extract all subnet IDs from a VPC
- ✅ Collect all security group IDs
- ✅ Get private IPs from instance list
- ✅ Extract ARNs for outputs
- ✅ Gather resource attributes for other resources

---

## 🚀 Next Steps

Proceed to **Day 11** to learn about Terraform's built-in functions and how to use them effectively in your configurations.

---

## 📚 Additional Resources

- [Terraform Conditional Expressions](https://www.terraform.io/language/expressions/conditionals)
- [Terraform Dynamic Blocks](https://www.terraform.io/language/expressions/dynamic-blocks)
- [Terraform Splat Expressions](https://www.terraform.io/language/expressions/splat)
- [Terraform For Expressions](https://www.terraform.io/language/expressions/for)

---

**Happy Learning! 🎉**
