Here is the complete **Day 13 Assignment** package.

This assignment focuses on using **Data Sources** to dynamically find existing infrastructure (Network) and using **Terraform Meta-Arguments (`count`)** to distribute new infrastructure (EC2s) across it.

-----

### 📋 Assignment Brief: "Dynamic Distribution"

**Objective:**
Deploy **4 EC2 Instances** into an **existing VPC**. The instances must be evenly distributed across **2 different existing subnets** (2 instances in Subnet A, 2 instances in Subnet B) without hardcoding any IDs.

**Requirements:**

1.  **Do NOT create a VPC or Subnets.** You must query AWS for an existing VPC and its subnets using `data` blocks.
2.  **Dynamic AMI:** Fetch the latest Amazon Linux 2 AMI automatically.
3.  **Looping:** Use `count` to create the 4 instances.
4.  **Logic:** Use Terraform math logic to ensure instances alternate between the two subnets.

-----

### 🛠️ The Solution Code (`main.tf`)

Save this code in a file named `main.tf`.

*Note: Update the `values = ["default"]` in the VPC filter to match your actual VPC name tag if it is not named "default".*

```hcl
provider "aws" {
  region = "us-east-1"  # Change to your region
}

# ---------------------------------------------------------
# 1. DATA SOURCES (Read-Only Information)
# ---------------------------------------------------------

# Step 1: Find the existing VPC
data "aws_vpc" "target_vpc" {
  filter {
    name   = "tag:Name"
    values = ["default"]  # <-- REPLACE with your VPC Name tag
  }
}

# Step 2: Find all subnets inside that VPC
data "aws_subnets" "available_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.target_vpc.id]
  }
}

# Step 3: Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ---------------------------------------------------------
# 2. RESOURCES (Creating the Infrastructure)
# ---------------------------------------------------------

resource "aws_instance" "app_server" {
  # Requirement: Create 4 instances
  count = 4

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  # -------------------------------------------------------
  # THE LOGIC: Distribute across subnets
  # -------------------------------------------------------
  # We use the modulo operator (%) to alternate subnets.
  # Instance 0 -> index 0 (Subnet 1)
  # Instance 1 -> index 1 (Subnet 2)
  # Instance 2 -> index 0 (Subnet 1)
  # Instance 3 -> index 1 (Subnet 2)
  # -------------------------------------------------------
  subnet_id = element(data.aws_subnets.available_subnets.ids, count.index % 2)

  tags = {
    Name = "Server-Instance-${count.index + 1}"
  }
}

# ---------------------------------------------------------
# 3. OUTPUTS (Verification)
# ---------------------------------------------------------

output "vpc_id_found" {
  value = data.aws_vpc.target_vpc.id
}

output "subnet_distribution" {
  value = {
    for i in aws_instance.app_server : i.tags.Name => i.subnet_id
  }
  description = "Shows which subnet each instance landed in"
}
```

-----

### 🧠 Code Explanation (How it works)

**1. `data "aws_subnets"` (Plural)**
Unlike `aws_subnet` (singular), which finds one specific subnet, the **plural** version returns a list of *all* matching subnet IDs in that VPC. This is crucial for the assignment because it gives us a list we can cycle through.

**2. The Distribution Logic (`count.index % 2`)**
We have a list of subnet IDs, and we want to alternate between them.

  * **Modulo (`%`)** returns the remainder of a division.
  * `0 % 2 = 0` (Selects 1st subnet ID)
  * `1 % 2 = 1` (Selects 2nd subnet ID)
  * `2 % 2 = 0` (Selects 1st subnet ID)
  * `3 % 2 = 1` (Selects 2nd subnet ID)

**3. `element()` Function**
`element(list, index)` retrieves an item from a list at a specific index. It handles the wrapping logic safely.

-----

### 🚀 How to Run

1.  **Prerequisites:** Ensure you have a VPC named "default" (or update the code to match your VPC's Name tag).
2.  **Initialize:**
    ```bash
    terraform init
    ```
3.  **Plan:** (Check the plan to see 4 instances being created and the Subnet IDs being assigned).
    ```bash
    terraform plan
    ```
4.  **Apply:**
    ```bash
    terraform apply --auto-approve
    ```
5.  **Verify:** Look at the `Outputs` in your terminal. You will see 4 servers, with two different subnet IDs used.
