
# Day 20: EKS Custom Modules Project Structure

## 1. Project Directory Layout
```text
day20/
├── main.tf          # Root Module: Orchestrator
├── variables.tf     # Root Variables
├── outputs.tf       # Root Outputs (to see results in terminal)
└── modules/
    └── vpc/         # Custom VPC Module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

```

---

## 2. Custom VPC Module (`modules/vpc/`)

### modules/vpc/variables.tf

```hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

```

### modules/vpc/main.tf

```hcl
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = { Name = "eks-custom-vpc" }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  map_public_ip_on_launch = true
}

```

### modules/vpc/outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

```

---

## 3. Root Module (`/day20/`)

### main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

# CALLING THE CUSTOM MODULE
module "my_vpc" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

# EKS MODULE (Example consuming VPC outputs)
module "eks" {
  source     = "./modules/eks" # Assuming you created this subfolder
  vpc_id     = module.my_vpc.vpc_id
  subnet_ids = module.my_vpc.public_subnet_ids
}

```

### outputs.tf

```hcl
output "final_vpc_id" {
  value = module.my_vpc.vpc_id
}

```

