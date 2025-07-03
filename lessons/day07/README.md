# Day 7: Type Constraints in Terraform

## Topics Covered
- String, number, bool types
- Map, set, list, tuple, object types
- Type validation and constraints
- Complex type definitions

## Key Learning Points

### Basic Types
1. **string** - Text values
2. **number** - Numeric values (integers and floats)
3. **bool** - Boolean values (true/false)

### Collection Types
1. **list(type)** - Ordered collection of values
2. **set(type)** - Unordered collection of unique values
3. **map(type)** - Key-value pairs with string keys
4. **tuple([type1, type2, ...])** - Ordered collection with specific types for each element
5. **object({key1=type1, key2=type2, ...})** - Structured data with named attributes

### Type Validation
Type constraints help catch errors early and make your code more maintainable by ensuring variables contain expected data types.

## Tasks for Practice

### Task: Using Files from Day 6
Update your variables.tf file from Day 6 to include these type constraints:

#### variables.tf with Type Constraints
```hcl
# String type
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

# Number type
variable "storage_disk_size" {
  description = "Storage disk size in GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.storage_disk_size >= 8 && var.storage_disk_size <= 1000
    error_message = "Storage disk size must be between 8 and 1000 GB."
  }
}

# Boolean type
variable "is_delete_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# List type
variable "allowed_locations" {
  description = "List of allowed AWS regions"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
  
  validation {
    condition = alltrue([
      for region in var.allowed_locations : contains([
        "us-east-1", "us-west-1", "us-west-2", 
        "eu-west-1", "eu-central-1", "ap-southeast-1"
      ], region)
    ])
    error_message = "All locations must be valid AWS regions."
  }
}

# Map type
variable "resource_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "terraform-learning"
    Owner       = "devops-team"
  }
}

# Tuple type
variable "network_config" {
  description = "Network configuration: [vpc_cidr, subnet_cidr, port]"
  type        = tuple([string, string, number])
  default     = ["10.0.0.0/16", "10.0.1.0/24", 80]
  
  validation {
    condition = (
      can(cidrhost(var.network_config[0], 0)) &&
      can(cidrhost(var.network_config[1], 0)) &&
      var.network_config[2] > 0 && var.network_config[2] < 65536
    )
    error_message = "Network config must contain valid CIDR blocks and port number."
  }
}

# List of allowed VM sizes
variable "allowed_instance_types" {
  description = "List of allowed EC2 instance types"
  type        = list(string)
  default     = ["t3.micro", "t3.small", "t3.medium"]
  
  validation {
    condition = alltrue([
      for instance_type in var.allowed_instance_types : 
      can(regex("^[a-z][0-9][a-z]?\\.(nano|micro|small|medium|large|xlarge|[0-9]+xlarge)$", instance_type))
    ])
    error_message = "All instance types must be valid EC2 instance types."
  }
}

# Object type for complex VM configuration
variable "vm_config" {
  description = "Virtual machine configuration"
  type = object({
    instance_type        = string
    ami_id              = string
    key_pair_name       = string
    monitoring_enabled  = bool
    storage_encrypted   = bool
    volume_size         = number
  })
  
  default = {
    instance_type       = "t3.micro"
    ami_id             = "ami-0c02fb55956c7d316"  # Amazon Linux 2
    key_pair_name      = "my-key-pair"
    monitoring_enabled = true
    storage_encrypted  = true
    volume_size        = 20
  }
  
  validation {
    condition = (
      var.vm_config.volume_size >= 8 && 
      var.vm_config.volume_size <= 1000
    )
    error_message = "Volume size must be between 8 and 1000 GB."
  }
}

# Set type (unique values)
variable "security_group_ports" {
  description = "Set of ports to open in security group"
  type        = set(number)
  default     = [22, 80, 443]
  
  validation {
    condition = alltrue([
      for port in var.security_group_ports : 
      port > 0 && port < 65536
    ])
    error_message = "All ports must be between 1 and 65535."
  }
}

# Complex object for database configuration
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine               = string
    engine_version       = string
    instance_class       = string
    allocated_storage    = number
    storage_encrypted    = bool
    backup_retention     = number
    multi_az            = bool
    publicly_accessible = bool
    deletion_protection = bool
    tags                = map(string)
  })
  
  default = {
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = "db.t3.micro"
    allocated_storage    = 20
    storage_encrypted    = true
    backup_retention     = 7
    multi_az            = false
    publicly_accessible = false
    deletion_protection = true
    tags = {
      Environment = "dev"
      Service     = "database"
    }
  }
  
  validation {
    condition = contains(["mysql", "postgres", "mariadb"], var.database_config.engine)
    error_message = "Database engine must be mysql, postgres, or mariadb."
  }
  
  validation {
    condition = (
      var.database_config.allocated_storage >= 20 && 
      var.database_config.allocated_storage <= 1000
    )
    error_message = "Allocated storage must be between 20 and 1000 GB."
  }
}

# Optional type with nullable
variable "kms_key_id" {
  description = "KMS key ID for encryption (optional)"
  type        = string
  default     = null
}

# Variable with sensitive flag
variable "database_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
  
  validation {
    condition = length(var.database_password) >= 8
    error_message = "Database password must be at least 8 characters long."
  }
}
```

#### terraform.tfvars with Type Examples
```hcl
# String
environment = "demo"

# Number
storage_disk_size = 50

# Boolean
is_delete_protection_enabled = true

# List
allowed_locations = ["us-east-1", "us-west-2", "eu-west-1"]

# Map
resource_tags = {
  Environment = "demo"
  Project     = "terraform-course"
  Owner       = "devops-team"
  Department  = "engineering"
}

# Tuple
network_config = ["10.0.0.0/16", "10.0.1.0/24", 8080]

# List of strings
allowed_instance_types = ["t3.micro", "t3.small", "t3.medium", "m5.large"]

# Complex object
vm_config = {
  instance_type       = "t3.small"
  ami_id             = "ami-0c02fb55956c7d316"
  key_pair_name      = "my-aws-key"
  monitoring_enabled = true
  storage_encrypted  = true
  volume_size        = 30
}

# Set
security_group_ports = [22, 80, 443, 8080]

# Complex database object
database_config = {
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 50
  storage_encrypted    = true
  backup_retention     = 14
  multi_az            = true
  publicly_accessible = false
  deletion_protection = true
  tags = {
    Environment = "demo"
    Service     = "mysql-database"
    Backup      = "enabled"
  }
}

# Sensitive variable (not recommended in .tfvars file)
# database_password = "super-secret-password"
```

#### locals.tf with Type Conversions
```hcl
locals {
  # Convert list to set
  unique_ports = toset(var.security_group_ports)
  
  # Convert number to string
  storage_size_string = tostring(var.storage_disk_size)
  
  # Convert boolean to string
  deletion_protection_flag = var.is_delete_protection_enabled ? "enabled" : "disabled"
  
  # Extract values from object
  vm_instance_type = var.vm_config.instance_type
  vm_volume_size   = var.vm_config.volume_size
  
  # Create map from tuple
  network_map = {
    vpc_cidr    = var.network_config[0]
    subnet_cidr = var.network_config[1]
    port        = var.network_config[2]
  }
  
  # Conditional object creation
  backup_config = var.database_config.backup_retention > 0 ? {
    enabled           = true
    retention_period  = var.database_config.backup_retention
    backup_window     = "03:00-04:00"
    maintenance_window = "sun:04:00-sun:05:00"
  } : {
    enabled = false
  }
  
  # Complex tag merging
  all_tags = merge(
    var.resource_tags,
    var.database_config.tags,
    {
      ManagedBy     = "Terraform"
      CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
      StorageSize   = "${var.storage_disk_size}GB"
      Environment   = upper(var.environment)
    }
  )
}
```

### Type Functions and Validation

#### Common Type Functions
```hcl
# Type conversion functions
locals {
  # String conversions
  number_as_string = tostring(42)
  bool_as_string   = tostring(true)
  list_as_string   = join(",", var.allowed_locations)
  
  # Number conversions
  string_as_number = tonumber("42")
  bool_as_number   = var.is_delete_protection_enabled ? 1 : 0
  
  # Boolean conversions
  string_as_bool = tobool("true")
  number_as_bool = var.storage_disk_size > 0
  
  # Collection conversions
  list_to_set    = toset(var.allowed_locations)
  set_to_list    = tolist(var.security_group_ports)
  map_to_list    = values(var.resource_tags)
  list_to_map    = zipmap(["a", "b", "c"], ["1", "2", "3"])
}
```

#### Advanced Validation Examples
```hcl
variable "cidr_blocks" {
  description = "List of CIDR blocks"
  type        = list(string)
  
  validation {
    condition = alltrue([
      for cidr in var.cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IPv4 CIDR notation."
  }
}

variable "instance_config" {
  description = "Instance configuration map"
  type        = map(string)
  
  validation {
    condition = alltrue([
      contains(keys(var.instance_config), "type"),
      contains(keys(var.instance_config), "ami"),
      length(var.instance_config["type"]) > 0
    ])
    error_message = "Instance config must contain 'type' and 'ami' keys."
  }
}
```

### Testing Type Constraints

```bash
# Validate configuration with type checking
terraform validate

# Plan with type validation
terraform plan

# Test invalid values (should fail)
terraform plan -var="storage_disk_size=5"  # Below minimum

# Test with valid values
terraform plan -var="environment=production" -var="storage_disk_size=100"
```

### Common Type Patterns

1. **Environment-specific configurations**
2. **Resource sizing based on type**
3. **Tag standardization**
4. **Network configuration validation**
5. **Security policy enforcement**

## Best Practices

1. **Always specify types** for variables
2. **Use validation blocks** for business rules
3. **Provide meaningful error messages**
4. **Use appropriate collection types** (list vs set vs map)
5. **Validate complex objects** thoroughly
6. **Use type conversion functions** when needed
7. **Document type requirements** in descriptions

## Next Steps
Proceed to Day 8 to learn about Terraform meta-arguments including count, for_each, and for loops for dynamic resource creation.
