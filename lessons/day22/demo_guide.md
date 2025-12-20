# 🚀 Day 22: RDS Database & Modular Terraform (Mini Project 8)

## 📋 Project Overview

This project demonstrates a production-ready, 3-tier architecture pattern on AWS using Terraform. It deploys a dynamic web application that securely connects to a managed relational database.

**Key Learning Objectives:**
1.  **Modular Terraform**: Breaking down complex infrastructure into reusable components (`vpc`, `ec2`, `rds`, `security_groups`, `secrets`).
2.  **Secret Management**: Eliminating hardcoded passwords by using **AWS Secrets Manager** and the Terraform `random` provider.
3.  **Secure Networking**: Placing databases in private subnets and using Security Groups to enforce least-privilege access.
4.  **Automated Bootstrapping**: Using EC2 `user_data` to install software and configure the application at launch.

---

## 🏗️ Architecture

The infrastructure is designed for security and high availability (at the network level).

```mermaid
graph TD
    User[User / Internet] -->|HTTP:80| IGW[Internet Gateway]
    IGW -->|Route Table| PublicSubnet[Public Subnet (US-East-1a)]
    
    subgraph VPC [VPC: 10.0.0.0/16]
        subgraph Public_Zone [Public Zone]
            EC2[EC2 Instance<br>Flask App]
        end
        
        subgraph Private_Zone [Private Zone]
            RDS[(RDS MySQL<br>Database)]
        end
    end
    
    EC2 -->|MySQL:3306| RDS
    EC2 -.->|Retrieve Password| SecretsManager[AWS Secrets Manager]
```

### Component Details

| Component | Specification | Description |
|-----------|---------------|-------------|
| **VPC** | `10.0.0.0/16` | Custom network with DNS hostnames enabled. |
| **Public Subnet** | `10.0.1.0/24` | Hosts the Web Server. Has direct internet access via IGW. |
| **Private Subnets** | `10.0.2.0/24`, `10.0.3.0/24` | Hosts the RDS instance. No direct internet access. Spans 2 AZs for RDS requirements. |
| **EC2 Instance** | `t2.micro` / Ubuntu 22.04 | Runs the Flask Python application. Bootstrapped via `user_data`. |
| **RDS Instance** | `db.t3.micro` / MySQL 8.0 | Managed database service. Placed in a DB Subnet Group. |
| **Secrets Manager** | Standard Secret | Stores the auto-generated database password securely. |

---

## 👨‍💻 Code Walkthrough

Here are the key code snippets to highlight during your demo:

### 1. The Secret Generator (`modules/secrets/main.tf`)
We don't ask the user for a password. We generate a strong one automatically and lock it in a vault.

```hcl
# Generate a random 16-character password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store it in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
  })
}
```

### 2. Wiring Modules (`main.tf`)
This is where the magic happens. We pass the output from the **Secrets** module directly into the **RDS** and **EC2** modules.

```hcl
module "rds" {
  source      = "./modules/rds"
  # ...
  db_password = module.secrets.db_password  # <--- Passing the secret
}

module "ec2" {
  source      = "./modules/ec2"
  # ...
  db_password = module.secrets.db_password  # <--- Passing the secret
}
```

### 3. Auto-Configuring the App (`modules/ec2/templates/user_data.sh`)
We use Terraform's `templatefile` function to inject these credentials into the Python code before the server even starts.

```python
# Inside the Python Flask App
DB_CONFIG = {
    "host": "${db_host}",         # Injected by Terraform
    "user": "${db_username}",     # Injected by Terraform
    "password": "${db_password}", # Injected by Terraform
    "database": "${db_name}"
}
```

### 4. Network Isolation (`modules/vpc/main.tf`)
We create a custom VPC with distinct public and private zones. The RDS instance is placed in private subnets, making it inaccessible from the public internet.

```hcl
# Private Subnets for RDS (requires at least 2 AZs)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = "${var.aws_region}a"
  # ...
}
```

### 5. Least Privilege Security (`modules/security_groups/main.tf`)
Instead of opening port 3306 to the world, we only allow traffic from the Web Server's security group.

```hcl
# Database Security Group
resource "aws_security_group" "db" {
  # ...
  ingress {
    description     = "MySQL from web server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id] # <--- Only allow the Web SG
  }
}
```

---

## 🛠️ Prerequisites

Before you begin, ensure you have:

1.  **Terraform installed** (v1.0+): `terraform version`
2.  **AWS CLI configured**: `aws configure` (Access Key, Secret Key, Region `us-east-1`)
3.  **IAM Permissions**: Your AWS user needs permissions for:
    *   EC2 (Instances, Security Groups, Key Pairs)
    *   VPC (VPCs, Subnets, Route Tables, IGWs)
    *   RDS (DB Instances, Subnet Groups)
    *   Secrets Manager (Create, Read, Delete Secrets)

---

## 🚀 Deployment Guide

### Step 1: Initialization
Initialize the Terraform working directory. This downloads the AWS provider and sets up the modules.

```bash
terraform init
```

### Step 2: Planning
Preview the changes. Terraform will calculate the dependency graph (e.g., VPC must be created before Subnets).

```bash
terraform plan
```

### Step 3: Application
Apply the configuration.

```bash
terraform apply -auto-approve
```

> ⏳ **Wait Time**: This step will take **5-10 minutes**. RDS instances take time to provision and become available.

---

## 🧪 Verification & Testing

### 1. Web Application Dashboard
Once `terraform apply` completes, look for the `application_url` in the outputs.

1.  Open the URL (e.g., `http://54.123.45.67`) in your browser.
2.  **Status Check**: You should see a green badge: **"● Connected to RDS"**.
3.  **Interactive Test**:
    *   Type a message (e.g., *"Hello from Terraform!"*) in the input box.
    *   Click **Save Message**.
    *   The page will reload, and your message should appear in the **"Recent Messages"** list.
    *   *This confirms the App (EC2) can write to the DB (RDS).*

### 2. AWS Console Verification

#### **EC2 Dashboard**
*   Go to **Instances**. Select `day22-rds-demo-web-server`.
*   Check the **Security** tab. Verify the Security Group allows Inbound Port 80 from `0.0.0.0/0`.

#### **RDS Dashboard**
*   Go to **Databases**. Select `day22-rds-demo-db`.
*   **Connectivity & security**: Verify it is in the `day22-rds-demo-vpc`.
*   **Security Group Rules**: Verify it allows Inbound Port 3306 **only** from the Web Server's Security Group ID (not `0.0.0.0/0`).

#### **Secrets Manager**
*   Go to **Secrets Manager**.
*   Find the secret `day22-rds-demo-dev-db-password-...`.
*   Click **Retrieve secret value**. You will see the random password that Terraform generated and the app is using.

---

## 🔍 Under the Hood: How it Works

### The "No-Hardcoded-Secrets" Workflow
1.  **Generation**: The `modules/secrets` module uses `resource "random_password"` to create a complex 16-char string.
2.  **Storage**: This string is immediately stored in `aws_secretsmanager_secret_version`.
3.  **Injection**:
    *   The password is passed as an output from `modules/secrets`.
    *   It is passed as an input variable to `modules/rds` (to set the master password).
    *   It is passed as an input variable to `modules/ec2`.
4.  **Usage**: The `modules/ec2` user_data script injects this password into the `app.py` file on the server.

### The Modular Structure
*   **Root (`main.tf`)**: The conductor. It calls child modules and passes data between them (e.g., passing `vpc_id` from the VPC module to the Security Group module).
*   **Child Modules**: Encapsulated logic for specific resources. This makes the code reusable and easier to maintain.

---

## ⚠️ Troubleshooting

| Issue | Possible Cause | Solution |
|-------|----------------|----------|
| **"Disconnected" status on App** | Database not ready yet or SG issues. | Wait 2-3 mins after deploy. Check if RDS status is "Available". |
| **Site can't be reached** | EC2 User Data failed or Security Group blocks port 80. | Check EC2 System Log (Actions > Monitor > Get System Log). Verify Inbound Rules. |
| **Terraform Error: "Error creating DB Instance"** | Password complexity requirements. | The `random_password` resource handles this, but ensure `special = true` is set. |

---

## 🧹 Cleanup

**Crucial Step**: RDS instances cost money even when idle. Destroy resources when finished.

```bash
terraform destroy -auto-approve
```
