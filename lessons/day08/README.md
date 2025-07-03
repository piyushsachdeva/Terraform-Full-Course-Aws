# Day 8: Meta-arguments

## Topics Covered
- Understanding count
- for_each loop
- for loop
- Practical examples

## Key Learning Points

### What are Meta-arguments?
Meta-arguments are special arguments that can be used with any resource type to change the behavior of how Terraform manages resources.

### Count Meta-argument
The `count` meta-argument accepts a whole number and creates that many instances of the resource.

**Benefits:**
- Creates multiple instances of the same resource
- Useful for simple resource duplication
- Each instance has a unique index (count.index)

**Use Cases:**
- Creating multiple EC2 instances
- Setting up multiple S3 buckets
- Deploying multiple security groups

### for_each Meta-argument
The `for_each` meta-argument accepts a map or set of strings and creates an instance for each item in that map or set.

**Benefits:**
- More flexible than count
- Better for complex resource management
- Each instance has a unique key
- Easier to add/remove specific instances

**Use Cases:**
- Creating resources based on variable lists
- Setting up users with different permissions
- Configuring multiple environments

### for Loop Expression
Terraform's for expression allows you to transform and filter collections.

**Syntax:**
- List: `[for item in list : expression]`
- Map: `{for key, value in map : key => expression}`

## Tasks for Practice

### Task 1: Multiple EC2 Instances with Count
Create 3 EC2 instances using the count meta-argument with different names.

### Task 2: S3 Buckets with for_each
Create multiple S3 buckets using for_each with a list of bucket names.

### Task 3: Security Groups with Dynamic Rules
Use for_each to create security group rules from a variable list.

### Task 4: Transform Lists with for Loop
Use for expressions to:
- Convert a list of instance names to uppercase
- Create a map from a list of values
- Filter a list based on conditions

### Task 5: Complex Resource Management
Combine count and for_each to create a more complex infrastructure setup.

## Common Patterns

### Pattern 1: Conditional Resource Creation
```hcl
count = var.create_instance ? 1 : 0
```

### Pattern 2: Dynamic Tagging
Use for expressions to create dynamic tags based on resource properties.

### Pattern 3: Resource Dependencies
Understand how count and for_each affect resource dependencies and references.

## Best Practices
- Use for_each when you need to manage resources individually
- Use count for simple duplication scenarios
- Avoid mixing count and for_each in the same configuration
- Be careful with resource ordering and dependencies

## Next Steps
Proceed to Day 9 to learn about Lifecycle meta-arguments and how to control resource creation and destruction behavior.
