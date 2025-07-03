# Day 10: Dynamic Blocks and Expressions

## Topics Covered
- Dynamic blocks
- Conditional expressions
- Splat expressions
- Practical examples

## Key Learning Points

### What are Dynamic Blocks?
Dynamic blocks allow you to create multiple nested blocks within a resource based on complex logic or external data sources.

**Benefits:**
- Eliminates code duplication
- Creates flexible configurations
- Supports complex nested structures
- Enables data-driven infrastructure

### Dynamic Block Syntax
```hcl
dynamic "block_name" {
  for_each = var.items
  content {
    # Block content using each.key and each.value
  }
}
```

### Conditional Expressions
Terraform's conditional expression uses ternary operator syntax to choose between two values.

**Syntax:** `condition ? true_value : false_value`

**Use Cases:**
- Setting resource attributes based on environment
- Choosing between different configurations
- Implementing feature flags

### Splat Expressions
Splat expressions extract values from complex data structures in a concise way.

**Syntax:**
- `list[*].attribute` - Extract attribute from all items
- `list[*]["key"]` - Extract specific key from all items

**Benefits:**
- Simplifies data extraction
- Works with lists and maps
- Reduces complex for loops

## Tasks for Practice

### Task 1: Dynamic Security Group Rules
Create a security group with dynamic ingress rules based on a variable list:
- HTTP (port 80) from anywhere
- HTTPS (port 443) from anywhere  
- SSH (port 22) from specific CIDR
- Custom application ports

### Task 2: Conditional Resource Creation
Use conditional expressions to:
- Create different instance types based on environment
- Enable/disable monitoring based on a variable
- Choose AMI based on region

### Task 3: Dynamic Tags
Create dynamic tags for resources based on:
- Environment variables
- Cost center mappings
- Project information
- Compliance requirements

### Task 4: Splat Expression Data Extraction
Practice splat expressions with:
- Extracting instance IDs from multiple EC2 instances
- Getting subnet IDs from VPC data sources
- Collecting security group IDs for outputs

### Task 5: Complex Infrastructure Pattern
Build a complete example combining:
- Dynamic blocks for multi-tier security groups
- Conditional expressions for environment-specific settings
- Splat expressions for resource references

## Practical Examples

### Example 1: Multi-Environment Load Balancer
Use dynamic blocks to create load balancer listeners based on environment requirements.

### Example 2: Auto Scaling Policies
Create dynamic auto scaling policies based on application metrics configuration.

### Example 3: Multi-Region Deployments
Use conditional expressions to handle region-specific configurations.

## Advanced Patterns

### Pattern 1: Nested Dynamic Blocks
Create complex nested structures like security groups with multiple rule types.

### Pattern 2: Conditional Dynamic Blocks
Combine conditional expressions with dynamic blocks for maximum flexibility.

### Pattern 3: Data Source Integration
Use dynamic blocks with data sources for infrastructure discovery.

## Best Practices
- Keep dynamic blocks simple and readable
- Use meaningful variable names in for_each
- Document complex conditional logic
- Test expressions in terraform console first
- Avoid over-complicating configurations

## Common Gotchas
- Remember that dynamic blocks create arrays
- Be careful with nested dynamic blocks
- Ensure proper error handling in conditions
- Watch out for circular dependencies

## Debugging Tips
- Use terraform console to test expressions
- Break complex expressions into smaller parts
- Use local values for intermediate calculations
- Add validation rules for input variables

## Next Steps
Proceed to Day 11 to learn about Terraform's built-in functions and how to use them effectively in your configurations.
