# Terraform Provisioners Demo Guide

## Overview
This guide demonstrates three types of Terraform provisioners:
1. **local-exec** - Runs commands on the machine executing Terraform
2. **remote-exec** - Runs commands on the provisioned resource via SSH
3. **file + remote-exec** - Copies files and executes them on the remote resource

Each provisioner is commented out by default in `main.tf`. You'll uncomment one at a time to see how each works.

---

## Prerequisites

Before starting this demo, ensure you have:

1. **AWS Credentials configured**
   ```bash
   # Verify AWS credentials are set
   aws sts get-caller-identity
   ```

2. **An EC2 Key Pair**
   
   Create a key pair using AWS CLI:
   
   ```bash
   aws ec2 create-key-pair --key-name terraform-demo-key \
     --query 'KeyMaterial' --output text > terraform-demo-key.pem
   chmod 400 terraform-demo-key.pem
   ```

3. **Required tools installed**
   - Terraform (v1.0+)
   - AWS CLI
   - SSH client

---

## Demo Setup

### Step 1: Initialize Terraform

```bash
cd lessons/day19/code/provisioner-demo
terraform init
```

Expected output: Terraform downloads the AWS provider and initializes the backend.

---

## Demo 1: local-exec Provisioner

**Purpose**: Execute commands on your local machine after resource creation.

### Step 1: Enable local-exec provisioner

Open `main.tf` and uncomment the local-exec provisioner block (around lines 68-72):

```hcl
provisioner "local-exec" {
  command = "echo 'Local-exec: created instance ${self.id} with IP ${self.public_ip}'"
}
```

### Step 2: Apply the configuration

```bash
terraform apply \
  -var='key_name=terraform-demo-key' \
  -var='private_key_path=./terraform-demo-key.pem'
```

### Step 3: Observe the output

Look for the local-exec output in the terminal during the apply process. You should see:
```
aws_instance.demo: Provisioning with 'local-exec'...
Local-exec: created instance i-xxxxxxxxx with IP x.x.x.x
```

### What happened?
- Terraform created the EC2 instance
- After successful creation, it ran the echo command **on your local machine**
- The instance ID and IP were interpolated from the resource

### Use Cases for local-exec:
- Trigger local scripts or webhooks
- Update local configuration files
- Call APIs or send notifications
- Register resources in external systems

### Step 4: Clean up this demo

Comment out the local-exec provisioner block in `main.tf` before moving to the next demo.

---

## Demo 2: remote-exec Provisioner

**Purpose**: Execute commands directly on the remote instance via SSH.

### Step 1: Enable remote-exec provisioner

In `main.tf`, uncomment the remote-exec provisioner block (around lines 89-94):

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "echo 'Hello from remote-exec' | sudo tee /tmp/remote_exec.txt",
  ]
}
```

**Important**: Ensure the connection block is uncommented (lines 52-57) - it should already be uncommented from the initial setup.

### Step 2: Re-create the instance

Since provisioners only run during resource creation, we need to recreate the instance:

```bash
# Mark the instance for recreation
terraform taint aws_instance.demo

# Apply with the new provisioner
terraform apply \
  -var='key_name=terraform-demo-key' \
  -var='private_key_path=./terraform-demo-key.pem'
```

### Step 3: Observe the output

During the apply, you'll see:
```
aws_instance.demo: Provisioning with 'remote-exec'...
aws_instance.demo: Still creating... [30s elapsed]
aws_instance.demo (remote-exec): Connecting to remote host via SSH...
aws_instance.demo (remote-exec): Connected!
aws_instance.demo (remote-exec): Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
aws_instance.demo (remote-exec): Reading package lists...
...
```

### Step 4: Verify the results

SSH into the instance and check the file:

```bash
# Get the instance IP from Terraform output
INSTANCE_IP=$(terraform output -raw public_ip)

# SSH into the instance (ubuntu user for Ubuntu AMI)
ssh -i terraform-demo-key.pem ubuntu@$INSTANCE_IP

# Check the file created by remote-exec
cat /tmp/remote_exec.txt
# Output: Hello from remote-exec

# Exit the SSH session
exit
```

### What happened?
- Terraform created the instance
- Waited for SSH to become available
- Connected via SSH using the connection block credentials
- Ran the commands **on the remote instance** (not your laptop)
- `sudo apt-get update` updated package lists on Ubuntu
- Created `/tmp/remote_exec.txt` file on the remote instance

### Use Cases for remote-exec:
- Install and configure software packages
- Run initialization scripts
- Update system configurations
- Start services or daemons

### Step 5: Clean up this demo

Comment out the remote-exec provisioner block in `main.tf` before moving to the next demo.

---

## Demo 3: file + remote-exec Provisioner

**Purpose**: Copy a script file to the instance and execute it remotely.

### Step 1: Review the script

Check the contents of `scripts/welcome.sh`:

```bash
cat scripts/welcome.sh
```

This script creates a welcome message and displays system information.

### Step 2: Enable file and remote-exec provisioners

In `main.tf`, uncomment both provisioner blocks (around lines 104-117):

```hcl
provisioner "file" {
  source      = "${path.module}/scripts/welcome.sh"
  destination = "/tmp/welcome.sh"
}

provisioner "remote-exec" {
  inline = [
    "sudo chmod +x /tmp/welcome.sh",
    "sudo /tmp/welcome.sh"
  ]
}
```

### Step 3: Re-create the instance

```bash
# Taint the instance
terraform taint aws_instance.demo

# Apply with the new provisioners
terraform apply \
  -var='key_name=terraform-demo-key' \
  -var='private_key_path=./terraform-demo-key.pem'
```

### Step 4: Observe the output

You'll see the file being copied and then executed:
```
aws_instance.demo: Provisioning with 'file'...
aws_instance.demo: Provisioning with 'remote-exec'...
aws_instance.demo: remote-exec: Welcome to the Provisioner Demo
aws_instance.demo: remote-exec: Linux ip-xxx-xxx-xxx-xxx 4.14.336-257.562.amzn2.x86_64 ...
```

### Step 5: Verify the results

SSH into the instance and check the files:

```bash
INSTANCE_IP=$(terraform output -raw public_ip)
ssh -i terraform-demo-key.pem ec2-user@$INSTANCE_IP

# Check the copied script
ls -l /tmp/welcome.sh

# Check the output file created by the script
cat /tmp/welcome_msg.txt

exit
```

### What happened?
- Terraform created the instance
- Copied `scripts/welcome.sh` from your local machine to `/tmp/welcome.sh` on the instance
- Made the script executable and ran it
- The script created `/tmp/welcome_msg.txt` with system information

### Use Cases for file + remote-exec:
- Deploy complex configuration scripts
- Copy application binaries or packages
- Transfer initialization data
- Deploy configuration files that require processing

---

## Advanced Topics

### Re-running Provisioners

Provisioners only run when a resource is **created** (or destroyed with `when = destroy`). To re-run provisioners without destroying other resources:

```bash
# Option 1: Taint the resource
terraform taint aws_instance.demo
terraform apply -var='key_name=...' -var='private_key_path=...'

# Option 2: Use replace flag (Terraform 0.15.2+)
terraform apply -replace=aws_instance.demo -var='key_name=...' -var='private_key_path=...'
```

### Provisioner Failure Behavior

By default, if a provisioner fails, Terraform marks the resource as **tainted**. On the next apply, Terraform will destroy and recreate it.

To change this behavior, use `on_failure`:

```hcl
provisioner "remote-exec" {
  inline = ["some-command"]
  
  on_failure = continue  # Options: continue, fail (default)
}
```

### Using Variables in Provisioners

You can reference Terraform variables and resource attributes:

```hcl
provisioner "local-exec" {
  command = "echo ${self.public_ip} >> inventory.txt"
}

provisioner "remote-exec" {
  inline = [
    "echo 'Environment: ${var.environment}' > /tmp/env.txt"
  ]
}
```

### Destroy-time Provisioners

Run commands when a resource is destroyed:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Instance ${self.id} is being destroyed' >> destroy.log"
}
```

---

## Best Practices

### ✅ DO:
- Use provisioners as a **last resort** - prefer cloud-init, user_data, or configuration management tools
- Keep provisioner scripts idempotent when possible
- Handle errors gracefully in your scripts
- Use `local-exec` for orchestration tasks outside the resource
- Test provisioners thoroughly in non-production environments

### ❌ DON'T:
- Rely on provisioners for critical configuration (they don't run on every apply)
- Use provisioners when a native Terraform resource would work
- Forget to handle network latency and timeouts
- Ignore provisioner failures without understanding the impact
- Store sensitive data in provisioner scripts

### When to Use Each Provisioner:

| Provisioner | Best For | Avoid For |
|-------------|----------|-----------|
| **local-exec** | Triggering webhooks, updating local files, calling APIs | Tasks that should run on every apply |
| **remote-exec** | Quick bootstrap commands, simple configurations | Complex deployments (use user_data instead) |
| **file** | Copying small config files or scripts | Large files or continuous deployment |

---

## Troubleshooting

### Issue: SSH Connection Timeout

**Symptoms**: Provisioner hangs with "Still creating..." message

**Solutions**:
1. Check security group allows SSH (port 22) from your IP
2. Verify the instance has a public IP
3. Ensure the key pair name matches an existing key in your region
4. Check the private key file path and permissions (should be 400)

```bash
# Add explicit timeout to connection block
connection {
  type        = "ssh"
  user        = "ubuntu"           # ubuntu for Ubuntu, ec2-user for Amazon Linux
  private_key = file(var.private_key_path)
  host        = self.public_ip
  timeout     = "5m"  # Add this
}
```

### Issue: Permission Denied (publickey)

**Symptoms**: SSH authentication failure

**Solutions**:
1. Verify the key pair name matches what's in AWS
2. Check private key file permissions: `chmod 400 terraform-demo-key.pem`
3. Ensure you're using the correct SSH user (ubuntu for Ubuntu AMI, ec2-user for Amazon Linux)
3. Ensure you're using the correct SSH user (ec2-user for Amazon Linux)

### Issue: Script Not Found

**Symptoms**: File provisioner fails to find source file

**Solutions**:
1. Use `${path.module}` to reference files relative to the module
2. Verify the script file exists: `ls -l scripts/welcome.sh`
3. Check file paths are correct in the provisioner block

---

## Cleanup

When you're done with all demos, destroy the resources:

```bash
terraform destroy \
  -var='key_name=terraform-demo-key' \
  -var='private_key_path=./terraform-demo-key.pem'
```

Also delete the key pair:

```bash
aws ec2 delete-key-pair --key-name terraform-demo-key
rm terraform-demo-key.pem
```

---

## Summary

You've learned:
- ✅ How to use **local-exec** to run commands on your local machine
- ✅ How to use **remote-exec** to configure instances via SSH
- ✅ How to combine **file** and **remote-exec** for script-based provisioning
- ✅ How to re-run provisioners using `taint` or `replace`
- ✅ Best practices and when to avoid provisioners

**Key Takeaway**: Provisioners are powerful but should be used sparingly. For most use cases, prefer declarative approaches like user_data, cloud-init, or configuration management tools (Ansible, Chef, Puppet).

---

## Next Steps

- Explore `null_resource` with provisioners for tasks not tied to a specific resource
- Learn about `when = destroy` provisioners for cleanup tasks
- Study alternative approaches: user_data, cloud-init, Packer for AMI creation
- Investigate configuration management integration (Ansible, Chef, Puppet)

Happy Terraforming! 🚀
