
# Day 19: Mastering Terraform Provisioners - Complete Code

This configuration launches an EC2 instance and uses three types of provisioners:
1. **File:** Uploads a setup script.
2. **Remote-exec:** Runs the script on the server.
3. **Local-exec:** Saves the instance IP to a local file.

## Prerequisites
Before running this, generate an SSH key pair in your project folder:
```bash
ssh-keygen -t rsa -b 2048 -f terraform-demo-key -N ""
chmod 400 terraform-demo-key

```

---

### 1. `variables.tf`

*Defines the inputs for our project.*

```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair in AWS"
  default     = "terraform-demo-key"
}

variable "private_key_path" {
  description = "Path to the private key file on your local machine"
  default     = "./terraform-demo-key"
}

```

---

### 2. `main.tf`

*The core logic containing resources and provisioners.*

```hcl
provider "aws" {
  region = var.aws_region
}

# 1. Upload the Public Key to AWS
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${var.private_key_path}.pub")
}

# 2. Security Group (Allow SSH)
resource "aws_security_group" "demo_sg" {
  name        = "demo-provisioner-sg"
  description = "Allow SSH inbound traffic"

  # WARNING: 0.0.0.0/0 is for demo only. Restrict in production!
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 4. EC2 Instance with Provisioners
resource "aws_instance" "demo" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  # Connection Block: Tells Terraform how to SSH into the instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }

  # Provisioner 1: File (Copy local script to remote)
  provisioner "file" {
    content     = <<EOF
#!/bin/bash
echo "Welcome to your Terraform-provisioned instance!" > /home/ubuntu/welcome.txt
sudo apt-get update -y
sudo apt-get install -y nginx
EOF
    destination = "/tmp/setup_script.sh"
  }

  # Provisioner 2: Remote-exec (Execute the script)
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_script.sh",
      "/tmp/setup_script.sh",
    ]
  }

  # Provisioner 3: Local-exec (Run on your machine)
  provisioner "local-exec" {
    command = "echo 'Instance ${self.public_ip} provisioned successfully!' > instance_ip.txt"
  }
}

```

---

### 3. `outputs.tf`

*Displays useful information after apply.*

```hcl
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.demo.public_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.demo.public_ip}"
}

```

---

### How to Run

1. **Initialize:**
```bash
terraform init

```


2. **Apply:**
```bash
terraform apply -auto-approve

```


3. **Verify:**
* check your local folder for `instance_ip.txt`.
* SSH into the instance and check if Nginx is installed.


```bash
ssh -i terraform-demo-key ubuntu@<OUTPUT_IP>
cat /home/ubuntu/welcome.txt

```


4. **Clean Up:**
```bash
terraform destroy -auto-approve

```



```

```