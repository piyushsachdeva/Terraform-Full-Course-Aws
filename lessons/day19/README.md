# Terraform Provisioners Demo

## 📚 What Are Provisioners?

**Provisioners** are Terraform's way to execute scripts or commands during resource creation or destruction. They enable you to perform actions that go beyond Terraform's declarative resource management.

### Key Concepts

- **Provisioners run during resource lifecycle events** (creation or destruction)
- **They are a "last resort"** - Terraform recommends using native cloud-init, user_data, or configuration management tools when possible
- **They execute only once** during resource creation (not on updates)
- **Failure handling**: By default, if a provisioner fails, the resource is marked as "tainted" and will be recreated on next apply

---

## 🔧 Types of Provisioners

This demo covers the three most common provisioner types:

### 1. **local-exec** Provisioner
- **Where it runs**: On the machine executing Terraform (your laptop, CI/CD server)
- **Connection required**: No
- **Use cases**:
  - Trigger webhooks or API calls
  - Update local inventory files
  - Run local scripts for orchestration
  - Send notifications (Slack, email)
  - Register resources in external systems

**Example**:
```hcl
provisioner "local-exec" {
  command = "echo ${self.public_ip} >> inventory.txt"
}
```

### 2. **remote-exec** Provisioner
- **Where it runs**: On the remote resource via SSH/WinRM
- **Connection required**: Yes (SSH for Linux, WinRM for Windows)
- **Use cases**:
  - Install packages (nginx, docker, etc.)
  - Run initialization commands
  - Configure system settings
  - Start services or daemons
  - Quick bootstrap tasks

**Example**:
```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx",
    "sudo systemctl start nginx"
  ]
}
```

### 3. **file** Provisioner
- **Where it runs**: Copies files from local to remote
- **Connection required**: Yes (SSH for Linux, WinRM for Windows)
- **Use cases**:
  - Copy configuration files
  - Deploy scripts for execution
  - Transfer SSL certificates
  - Upload application binaries

**Example**:
```hcl
provisioner "file" {
  source      = "scripts/setup.sh"
  destination = "/tmp/setup.sh"
}

provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/setup.sh",
    "/tmp/setup.sh"
  ]
}
```

---

## 🎯 Provisioner Best Practices

### ✅ DO:
- Use provisioners as a **last resort**
- Prefer cloud-init, user_data, or AMI baking (Packer)
- Keep provisioner scripts idempotent
- Handle errors gracefully with `on_failure` parameter
- Use `connection` timeouts to avoid hanging
- Test thoroughly in non-production environments

### ❌ DON'T:
- Use provisioners when native Terraform resources exist
- Rely on provisioners for critical configuration
- Forget that provisioners only run on creation
- Store sensitive data in provisioner commands
- Use complex logic - move to proper config management tools

---

## 🔄 Connection Block

For **remote-exec** and **file** provisioners, you need a `connection` block:

```hcl
connection {
  type        = "ssh"              # or "winrm" for Windows
  user        = "ubuntu"           # SSH user
  private_key = file("~/.ssh/id_rsa")  # SSH private key
  host        = self.public_ip     # Target host
  timeout     = "5m"               # Connection timeout
}
```

---

## 📖 Demo Overview

This small demo shows three provisioner techniques and how to enable them one at a time for teaching:

- **local-exec**: runs on the machine where Terraform runs
- **remote-exec**: runs over SSH on the target instance
- **file + remote-exec**: copies a script and executes it remotely

How to use
1. Prerequisites
   - AWS credentials available (environment variables, shared credentials, or other supported mechanism)
   - An existing EC2 key pair in the chosen region (set `var.key_name`)
   - The private key file available locally (set `var.private_key_path` to the path)

2. Quick demo steps (recommended flow)
   - Open `main.tf` and leave all provisioner blocks commented by default.
   - Uncomment the provisioner block you want to test (only one at a time).
   - Initialize: `terraform init`
   - Create resources: `terraform apply -var='key_name=YOUR_KEY' -var='private_key_path=/path/to/key.pem' -auto-approve`

3. Re-run a provisioner after changes
   Provisioners run when a resource is created (and some run on destroy). To re-run a provisioner on the same resource:
   - `terraform taint aws_instance.demo`  # marks resource for recreation
   - `terraform apply -var='key_name=YOUR_KEY' -var='private_key_path=/path/to/key.pem' -auto-approve`

4. Helpful tips
   - If your instance is in a private subnet or not reachable from your machine, the remote-exec and file provisioners will fail.
   - Use `local-exec` for local integration tasks (e.g., copying artifacts to a registry), and remote-based provisioners for instance-level bootstrapping.
   - When teaching: uncomment one block, run apply, show results, then comment it back (or taint to re-run).

Files
- `main.tf` - instance, security group and commented provisioner blocks
- `provider.tf` - provider and region variable
- `variables.tf` - required variables (key name, private key path)
- `backend.tf` - example S3 backend (commented)
- `outputs.tf` - public IP and instance ID
- `scripts/welcome.sh` - sample script used by the file provisioner
- `demo.sh` - helper script to initialize & apply (simple)

---

## 🚨 Important Notes

### Provisioner Execution Timing

**Provisioners only run during resource CREATION** (and optionally destruction). They do NOT run:
- On resource updates
- When you change provisioner code
- During `terraform plan`
- On every `terraform apply`

**To re-run a provisioner**, you must recreate the resource:
```bash
# Option 1: Taint the resource
terraform taint aws_instance.demo

# Option 2: Use replace flag (Terraform 0.15.2+)
terraform apply -replace=aws_instance.demo
```

### Failure Behavior

By default, if a provisioner fails:
1. The resource creation is considered **failed**
2. The resource is marked as **tainted**
3. Next apply will **destroy and recreate** it

You can change this behavior:
```hcl
provisioner "remote-exec" {
  inline = ["some-command"]
  
  on_failure = continue  # Options: fail (default) | continue
}
```

### Destroy-Time Provisioners

Run actions when a resource is destroyed:
```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Cleaning up ${self.id}'"
}
```

---

## 🆚 Alternatives to Provisioners

Before using provisioners, consider these alternatives:

| Alternative | Use Case | Pros |
|-------------|----------|------|
| **user_data** / **cloud-init** | EC2 instance initialization | Native, runs on every boot, no SSH needed |
| **Packer** | Pre-bake AMIs | Faster deployments, immutable infrastructure |
| **Ansible/Chef/Puppet** | Configuration management | Better for complex setups, mature tooling |
| **AWS Systems Manager** | Post-deployment config | No SSH, works in private subnets |
| **Container images** | Application deployment | Portable, version controlled |

---

## 📚 Additional Resources

- [Terraform Provisioners Documentation](https://www.terraform.io/docs/language/resources/provisioners/syntax.html)
- [Why Provisioners Are Last Resort](https://www.terraform.io/docs/language/resources/provisioners/syntax.html#provisioners-are-a-last-resort)
- [AWS EC2 User Data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
- [Packer by HashiCorp](https://www.packer.io/)

---

## 🔒 Safety Note

- **Never share your private key** or commit it to version control
- Use `.gitignore` to exclude `*.pem` files
- Clean up resources after demo with `terraform destroy`
- Review security group rules (SSH should be restricted to your IP)
