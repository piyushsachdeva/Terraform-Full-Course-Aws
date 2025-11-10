# VPC Peering Demo - File Structure

This document explains the architecture and organization of the VPC peering demo project.

## 📁 Project Structure

```
day15/
├── main.tf                    # Core infrastructure resources
├── variables.tf               # Variable declarations
├── outputs.tf                 # Output definitions
├── providers.tf               # AWS provider configurations
├── versions.tf                # Terraform & provider version constraints
├── backend.tf                 # Remote state configuration (S3 + DynamoDB)
├── data.tf                    # Data sources (AMIs, AZs)
├── locals.tf                  # Local values and templates
├── terraform.tfvars.example   # Example configuration file
├── .gitignore                 # Git ignore patterns
├── README.md                  # Main documentation
├── QUICKSTART.md              # 5-minute quick start guide
├── DEMO-BUILD.md              # 30-step detailed walkthrough
├── FILE-STRUCTURE.md          # This file
├── PROJECT-SUMMARY.md         # Project overview
└── VERSIONS.md                # Version history

```

## 📄 File Descriptions

### Core Terraform Files

#### `main.tf`
**Purpose:** Contains all infrastructure resources
**Contains:**
- VPC resources (Primary & Secondary)
- Subnets (public subnets in each VPC)
- Internet Gateways
- Route Tables and Associations
- VPC Peering Connection & Accepter
- Routes for peering traffic
- Security Groups
- EC2 Instances

**Why separate from other files?**
- Keeps resource definitions clean and focused
- Easier to navigate and modify infrastructure
- Follows Terraform best practices for large projects

#### `variables.tf`
**Purpose:** Declares all input variables
**Contains:**
- Region configurations
- VPC CIDR blocks
- Subnet CIDR blocks
- Instance type
- SSH key name

**Best Practice:**
- All variables have descriptions
- Default values provided for convenience
- Type constraints ensure correct input

#### `outputs.tf`
**Purpose:** Defines outputs for important resource attributes
**Contains:**
- VPC IDs and CIDR blocks
- Peering connection details
- Instance IDs and IP addresses
- Testing instructions

**Usage:**
```powershell
terraform output
terraform output -raw primary_instance_public_ip
```

#### `providers.tf`
**Purpose:** Configures AWS providers for multi-region deployment
**Contains:**
- Primary provider (us-east-1)
- Secondary provider (us-west-2)

**Why separate?**
- Clear separation of provider configuration
- Easy to modify regions
- Follows HashiCorp recommendations

#### `versions.tf`
**Purpose:** Specifies Terraform and provider version constraints
**Contains:**
- Required Terraform version (>= 1.6.0)
- AWS provider version (~> 6.20.0)

**Best Practice:**
- Prevents version conflicts
- Ensures reproducible deployments
- Documents compatible versions

#### `backend.tf`
**Purpose:** Configures remote state storage
**Contains:**
- S3 backend configuration
- DynamoDB table for state locking
- Encryption settings

**Benefits:**
- Team collaboration
- State locking prevents conflicts
- Secure state storage

#### `data.tf`
**Purpose:** Defines data sources for dynamic lookups
**Contains:**
- Availability zones for both regions
- Latest Amazon Linux 2 AMIs for both regions

**Why data sources?**
- Always uses latest AMIs
- Automatically selects available AZs
- No hardcoded values

#### `locals.tf`
**Purpose:** Defines computed values and templates
**Contains:**
- Common tags
- Regional configurations
- HTML templates for web servers

**Advantages:**
- Reduces code duplication
- Centralized configuration
- Easier to maintain

### Configuration Files

#### `terraform.tfvars.example`
**Purpose:** Example configuration file
**Usage:**
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

**Note:** `terraform.tfvars` is gitignored to prevent committing sensitive data

#### `.gitignore`
**Purpose:** Prevents committing sensitive files
**Excludes:**
- State files
- `.terraform/` directory
- `*.tfvars` (except examples)
- SSH keys (`.pem`, `.pub`)
- Lock files

### Documentation Files

#### `README.md`
**Purpose:** Main comprehensive documentation
**Audience:** All users
**Contains:**
- Project overview
- Architecture diagram
- Complete setup instructions
- Testing procedures
- Troubleshooting guide

#### `QUICKSTART.md`
**Purpose:** Rapid deployment guide
**Audience:** Experienced users
**Contains:**
- 5-minute deployment steps
- Quick test procedures
- Common issues and fixes

#### `DEMO-BUILD.md`
**Purpose:** Detailed step-by-step walkthrough
**Audience:** Learners and beginners
**Contains:**
- 30 detailed steps
- Verification at each stage
- Expected outputs
- Advanced testing scenarios

#### `FILE-STRUCTURE.md`
**Purpose:** Architecture and organization guide (this file)
**Audience:** Developers and contributors
**Contains:**
- File structure explanation
- Design decisions
- Best practices

#### `PROJECT-SUMMARY.md`
**Purpose:** High-level project overview
**Audience:** Stakeholders and reviewers
**Contains:**
- Project goals
- Key features
- Architecture summary

#### `VERSIONS.md`
**Purpose:** Version tracking
**Audience:** Maintainers
**Contains:**
- Terraform version history
- Provider version history
- Breaking changes

## 🏗️ Architecture Decisions

### Why Separate Files?

**Monolithic (`main.tf` only):**
- ❌ Hard to navigate
- ❌ Merge conflicts
- ❌ Difficult to maintain

**Modular (Multiple files):**
- ✅ Clear separation of concerns
- ✅ Easy to locate resources
- ✅ Better team collaboration
- ✅ Follows Terraform conventions

### File Organization Best Practices

1. **`main.tf`**: Core resources only
2. **`variables.tf`**: All inputs
3. **`outputs.tf`**: All outputs
4. **`providers.tf`**: Provider configurations
5. **`versions.tf`**: Version constraints
6. **`data.tf`**: Data source lookups
7. **`locals.tf`**: Computed values
8. **`backend.tf`**: State configuration

### Multi-Region Architecture

```
┌─────────────────────────────────────┐
│         providers.tf                │
│  ┌─────────────┐  ┌──────────────┐ │
│  │   Primary   │  │  Secondary   │ │
│  │  us-east-1  │  │  us-west-2   │ │
│  └─────────────┘  └──────────────┘ │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│            main.tf                  │
│  ┌─────────────────────────────┐   │
│  │  VPCs, Subnets, Peering,   │   │
│  │  Security Groups, Instances │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│           data.tf                   │
│  ┌─────────────────────────────┐   │
│  │  AZs, AMIs (both regions)  │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## 🔄 Terraform Workflow

```
1. terraform init
   ├── Downloads providers (aws ~> 6.20.0)
   ├── Initializes backend (S3 + DynamoDB)
   └── Creates .terraform/ directory

2. terraform plan
   ├── Reads: variables.tf, terraform.tfvars
   ├── Evaluates: locals.tf, data.tf
   ├── Plans: main.tf resources
   └── Shows: outputs.tf preview

3. terraform apply
   ├── Creates resources in main.tf
   ├── Stores state in backend.tf location
   └── Displays outputs from outputs.tf

4. terraform destroy
   └── Removes all resources
```

## 📊 Resource Dependencies

```
VPCs (Primary & Secondary)
  ↓
Subnets (requires VPCs, AZs from data.tf)
  ↓
Internet Gateways (requires VPCs)
  ↓
Route Tables (requires VPCs, IGWs)
  ↓
VPC Peering Connection (requires both VPCs)
  ↓
VPC Peering Accepter (requires Peering Connection)
  ↓
Routes (requires Route Tables, Peering Connection)
  ↓
Security Groups (requires VPCs)
  ↓
EC2 Instances (requires Subnets, SGs, AMIs from data.tf, Peering Accepter)
```

## 🎯 Best Practices Implemented

1. **Separation of Concerns**
   - Each file has a single responsibility
   - Easy to locate and modify resources

2. **DRY Principle**
   - locals.tf for reusable values
   - data.tf for dynamic lookups
   - No hardcoded values

3. **Security**
   - Encrypted state (backend.tf)
   - State locking (DynamoDB)
   - Gitignored sensitive files

4. **Documentation**
   - Multiple docs for different audiences
   - Inline comments in code
   - Architecture diagrams

5. **Version Control**
   - Version constraints (versions.tf)
   - Version history (VERSIONS.md)
   - Proper .gitignore

6. **Team Collaboration**
   - Remote state backend
   - Clear file organization
   - Comprehensive documentation

## 🔧 Customization Guide

### To Modify Regions
**Edit:** `variables.tf` (default values) or `terraform.tfvars`

### To Change CIDR Blocks
**Edit:** `terraform.tfvars`
**Remember:** Ensure no overlap for peering to work

### To Add More Subnets
**Edit:** `main.tf` (add resources)
**Update:** `outputs.tf` (expose new subnet IDs)

### To Change Instance Type
**Edit:** `terraform.tfvars` (change `instance_type`)

### To Customize User Data
**Edit:** `locals.tf` (modify HTML templates)

### To Add More Regions
**Edit:**
1. `providers.tf` (add new provider)
2. `variables.tf` (add region variable)
3. `main.tf` (add VPC resources)
4. `data.tf` (add AZ and AMI lookups)

## 📚 Related Documentation

- **Quick Deploy:** See `QUICKSTART.md`
- **Detailed Guide:** See `DEMO-BUILD.md`
- **Main Docs:** See `README.md`
- **Version Info:** See `VERSIONS.md`
- **Project Overview:** See `PROJECT-SUMMARY.md`

---

**Questions?** Check the troubleshooting sections in README.md or DEMO-BUILD.md
