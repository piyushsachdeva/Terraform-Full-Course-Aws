# VPC Peering Demo - Complete Build Guide

This is a comprehensive, step-by-step guide to build, deploy, and test the VPC Peering demo from scratch.

## ⚠️ CRITICAL: SSH Key Security

**Before you begin**, understand that PEM key files MUST be properly secured or SSH will fail!

**For Windows users:**
- ❌ `chmod 400` does NOT work (it's a Linux command)
- ✅ Use `icacls` commands to set Windows ACL permissions
- See [Step 4.1](#step-41-secure-your-pem-key-files-critical) for detailed instructions

**For Linux/Ubuntu/Mac users:**
- ✅ Use `chmod 400` to restrict permissions
- See [Step 4.1](#step-41-secure-your-pem-key-files-critical) for detailed instructions

**Common SSH username:**
- ❌ NOT `ec2-user` for Ubuntu
- ✅ Use `ubuntu` as the SSH username

## Table of Contents
1. [Prerequisites Setup](#prerequisites-setup)
2. [Infrastructure Deployment](#infrastructure-deployment)
3. [Verification Steps](#verification-steps)
4. [Testing Connectivity](#testing-connectivity)
5. [Advanced Testing](#advanced-testing)
6. [Cleanup](#cleanup)

---

## Prerequisites Setup

### Step 1: Verify AWS CLI Installation
```powershell
# Check AWS CLI version
aws --version

# If not installed, download from: https://aws.amazon.com/cli/
```

Expected output: `aws-cli/2.x.x Python/3.x.x Windows/10`

### Step 2: Configure AWS Credentials
```powershell
# Configure AWS CLI with your credentials
aws configure

# Enter your credentials when prompted:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### Step 3: Verify Terraform Installation
```powershell
# Check Terraform version
terraform version

# If not installed, download from: https://www.terraform.io/downloads
```

Expected output: `Terraform v1.x.x`

### Step 4: Create SSH Key Pairs

**For US-EAST-1:**
```powershell
# Create key pair in us-east-1
aws ec2 create-key-pair `
  --key-name vpc-peering-demo-east `
  --region us-east-1 `
  --query 'KeyMaterial' `
  --output text | Out-File -FilePath vpc-peering-demo-east.pem -Encoding ASCII

# Verify the key was created
aws ec2 describe-key-pairs --region us-east-1 --key-names vpc-peering-demo-east
```

**For US-WEST-2:**
```powershell
# Create key pair in us-west-2
aws ec2 create-key-pair `
  --key-name vpc-peering-demo-west `
  --region us-west-2 `
  --query 'KeyMaterial' `
  --output text | Out-File -FilePath vpc-peering-demo-west.pem -Encoding ASCII

# Verify the key was created
aws ec2 describe-key-pairs --region us-west-2 --key-names vpc-peering-demo-west
```

### Step 4.1: Secure Your PEM Key Files (CRITICAL!)

**⚠️ IMPORTANT:** PEM files must have restricted permissions or SSH will reject them with errors like:
- `WARNING: UNPROTECTED PRIVATE KEY FILE!`
- `Permissions 0644 are too open`
- `Load key "file.pem": invalid format`

#### **For Windows Users (PowerShell):**

**Why `chmod 400` doesn't work on Windows:**
- `chmod` is a Linux/Unix command that only works in WSL/Git Bash
- Windows uses ACLs (Access Control Lists), not Unix permissions
- Even if you run `chmod 400` in Git Bash, **Windows SSH still checks Windows NTFS permissions**
- You MUST use `icacls` to properly secure PEM files on Windows

**Secure the East PEM file:**
```powershell
# Remove all inherited permissions (critical step!)
icacls vpc-peering-demo-east.pem /inheritance:r

# Grant read-only access ONLY to your user account
icacls vpc-peering-demo-east.pem /grant:r "$($env:USERNAME):R"

# Verify permissions (should show only your username with R)
icacls vpc-peering-demo-east.pem
```

**Secure the West PEM file:**
```powershell
# Remove all inherited permissions
icacls vpc-peering-demo-west.pem /inheritance:r

# Grant read-only access ONLY to your user account
icacls vpc-peering-demo-west.pem /grant:r "$($env:USERNAME):R"

# Verify permissions
icacls vpc-peering-demo-west.pem
```

**Expected output after verification:**
```
vpc-peering-demo-east.pem YourUsername:(R)
Successfully processed 1 files; Failed processing 0 files
```

#### **For Linux/Ubuntu/Mac Users (Bash/Terminal):**

**Why strict permissions are required:**
- SSH refuses to use keys that other users can read
- This prevents unauthorized access to your private keys
- `chmod 400` = read-only for owner, no access for anyone else

**Secure both PEM files:**
```bash
# Set read-only permissions for owner only
chmod 400 vpc-peering-demo-east.pem
chmod 400 vpc-peering-demo-west.pem

# Verify permissions (should show -r--------)
ls -la vpc-peering-demo-*.pem
```

**Expected output:**
```
-r-------- 1 username username 1704 Nov 10 21:46 vpc-peering-demo-east.pem
-r-------- 1 username username 1704 Nov 10 21:46 vpc-peering-demo-west.pem
```

#### **Common SSH Permission Errors and Solutions:**

| Error | Cause | Solution |
|-------|-------|----------|
| `UNPROTECTED PRIVATE KEY FILE!` | Permissions too open | Run `icacls` (Windows) or `chmod 400` (Linux) |
| `Load key: invalid format` | Wrong file encoding (UTF-8 with BOM) | Recreate with `-Encoding ASCII` flag |
| `Permission denied (publickey)` | Wrong key or wrong username | Verify key name matches Terraform config |
| `Bad permissions` | Inherited Windows permissions | Run `icacls /inheritance:r` first |

#### **How to Restore Normal Permissions (For Easy Deletion):**

After securing PEM files with restricted permissions, you may encounter "Access Denied" errors when trying to delete them. Here's how to restore normal permissions:

**For Windows (PowerShell):**
```powershell
# Grant full control to allow deletion of the PEM files
icacls vpc-peering-demo-east.pem /grant:r "$($env:USERNAME):F"
icacls vpc-peering-demo-west.pem /grant:r "$($env:USERNAME):F"

# Now you can delete them normally
Remove-Item vpc-peering-demo-east.pem -Force
Remove-Item vpc-peering-demo-west.pem -Force
```

**For Linux/Ubuntu/Mac (Bash/Terminal):**
```bash
# Restore write permissions to allow deletion
chmod 600 vpc-peering-demo-east.pem
chmod 600 vpc-peering-demo-west.pem

# Or grant full permissions
chmod 644 vpc-peering-demo-east.pem
chmod 644 vpc-peering-demo-west.pem

# Now you can delete them normally
rm vpc-peering-demo-east.pem vpc-peering-demo-west.pem
```

**Why this is needed:**
- **Windows:** The `icacls /inheritance:r` command removes all permissions except read-only. To delete, you need write permissions (`F` = Full control).
- **Linux:** The `chmod 400` command makes files read-only. To delete, you need write permissions on the parent directory (which you usually have), but setting `chmod 600` or `644` makes it clearer.

**Quick cleanup command (Windows):**
```powershell
# One-liner to restore permissions and delete both PEM files
icacls *.pem /grant:r "$($env:USERNAME):F"; Remove-Item *.pem -Force
```

**Quick cleanup command (Linux/Mac):**
```bash
# One-liner to restore permissions and delete both PEM files
chmod 644 *.pem && rm *.pem
```

**Important:** Keep these `.pem` files secure! They are needed to SSH into instances.

---

## Infrastructure Deployment

### Step 5: Navigate to Project Directory
```powershell
cd c:\repos\Terraform-Full-Course-Aws\lessons\day15
```

### Step 6: Create Configuration File
```powershell
# Copy the example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Open in notepad to edit
notepad terraform.tfvars
```

**Update `terraform.tfvars` with your settings:**
```hcl
primary_region   = "us-east-1"
secondary_region = "us-west-2"

primary_vpc_cidr   = "10.0.0.0/16"
secondary_vpc_cidr = "10.1.0.0/16"

primary_subnet_cidr   = "10.0.1.0/24"
secondary_subnet_cidr = "10.1.1.0/24"

instance_type = "t2.micro"

# Use the key pair name we created
key_name = "vpc-peering-demo"
```

Save and close the file.

### Step 7: Initialize Terraform
```powershell
# Initialize Terraform - downloads providers and modules
terraform init
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

### Step 8: Format and Validate
```powershell
# Format the code
terraform fmt

# Validate the configuration
terraform validate
```

**Expected output:** `Success! The configuration is valid.`

### Step 9: Review the Execution Plan
```powershell
# Create an execution plan
terraform plan
```

**Review the plan output carefully. You should see:**
- 2 VPCs to be created
- 2 Subnets
- 2 Internet Gateways
- 2 Route Tables
- 2 Route Table Associations
- 1 VPC Peering Connection
- 1 VPC Peering Connection Accepter
- 2 Routes (for peering)
- 2 Security Groups
- 2 EC2 Instances
- Data sources for AZs and AMIs

**Total: ~17-18 resources to be created**

### Step 10: Apply the Configuration
```powershell
# Apply the configuration
terraform apply
```

Type `yes` when prompted.

**This will take approximately 3-5 minutes.** The process includes:
1. Creating VPCs in both regions (30 seconds)
2. Setting up networking components (1 minute)
3. Establishing VPC peering (30 seconds)
4. Launching EC2 instances (2-3 minutes)
5. Installing Apache on instances (1 minute)

**Monitor the output for any errors.**

### Step 11: Save Outputs
```powershell
# Display all outputs
terraform output

# Save outputs to a file for reference
terraform output | Out-File -FilePath deployment-info.txt
```

**Expected outputs:**
```
primary_instance_private_ip = "10.0.1.xxx"
primary_instance_public_ip = "x.x.x.x"
primary_vpc_id = "vpc-xxxxxxxxx"
secondary_instance_private_ip = "10.1.1.xxx"
secondary_instance_public_ip = "y.y.y.y"
secondary_vpc_id = "vpc-yyyyyyyyy"
vpc_peering_connection_id = "pcx-xxxxxxxxx"
vpc_peering_status = "active"
```

---

## Verification Steps

### Step 12: Verify VPC Creation
```powershell
# Check Primary VPC
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Name,Values=Primary-VPC-us-east-1"

# Check Secondary VPC
aws ec2 describe-vpcs --region us-west-2 --filters "Name=tag:Name,Values=Secondary-VPC-us-west-2"
```

### Step 13: Verify VPC Peering Status
```powershell
# Get peering connection ID
$PEERING_ID = (terraform output -raw vpc_peering_connection_id)

# Check peering connection details
aws ec2 describe-vpc-peering-connections --region us-east-1 --vpc-peering-connection-ids $PEERING_ID
```

**Verify that:**
- Status = "active"
- Requester VPC CIDR = 10.0.0.0/16
- Accepter VPC CIDR = 10.1.0.0/16

### Step 14: Verify Route Tables
```powershell
# Get Primary VPC ID
$PRIMARY_VPC_ID = (terraform output -raw primary_vpc_id)

# Check routes in Primary VPC
aws ec2 describe-route-tables --region us-east-1 --filters "Name=vpc-id,Values=$PRIMARY_VPC_ID"

# Get Secondary VPC ID
$SECONDARY_VPC_ID = (terraform output -raw secondary_vpc_id)

# Check routes in Secondary VPC
aws ec2 describe-route-tables --region us-west-2 --filters "Name=vpc-id,Values=$SECONDARY_VPC_ID"
```

**Look for routes with:**
- Destination: 10.1.0.0/16 (in Primary VPC route table)
- Destination: 10.0.0.0/16 (in Secondary VPC route table)
- Target: VPC Peering Connection ID

### Step 15: Verify EC2 Instances
```powershell
# Check Primary instance
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=Primary-VPC-Instance"

# Check Secondary instance
aws ec2 describe-instances --region us-west-2 --filters "Name=tag:Name,Values=Secondary-VPC-Instance"
```

**Verify that:**
- Instances are in "running" state
- Security groups are attached
- Public and private IPs are assigned

### Step 16: Verify Security Groups
```powershell
# Get Primary Security Group
$PRIMARY_INSTANCE_ID = (terraform output -raw primary_instance_id)
aws ec2 describe-security-groups --region us-east-1 --filters "Name=group-name,Values=primary-vpc-sg"

# Get Secondary Security Group
$SECONDARY_INSTANCE_ID = (terraform output -raw secondary_instance_id)
aws ec2 describe-security-groups --region us-west-2 --filters "Name=group-name,Values=secondary-vpc-sg"
```

**Verify that security groups allow:**
- SSH (port 22) from 0.0.0.0/0
- ICMP from peered VPC CIDR
- All TCP from peered VPC CIDR

---

## Testing Connectivity

### Step 17: Get Instance Information
```powershell
# Store important values
$PRIMARY_PUBLIC_IP = (terraform output -raw primary_instance_public_ip)
$PRIMARY_PRIVATE_IP = (terraform output -raw primary_instance_private_ip)
$SECONDARY_PUBLIC_IP = (terraform output -raw secondary_instance_public_ip)
$SECONDARY_PRIVATE_IP = (terraform output -raw secondary_instance_private_ip)

# Display the values
Write-Host "Primary Public IP: $PRIMARY_PUBLIC_IP"
Write-Host "Primary Private IP: $PRIMARY_PRIVATE_IP"
Write-Host "Secondary Public IP: $SECONDARY_PUBLIC_IP"
Write-Host "Secondary Private IP: $SECONDARY_PRIVATE_IP"
```

### Step 18: Test SSH Access

**IMPORTANT:** Ubuntu AMI uses `ubuntu` as the default user, NOT `ec2-user`!

**Test Primary Instance:**

*For Windows PowerShell:*
```powershell
# SSH into Primary instance (us-east-1)
ssh -i .\vpc-peering-demo-east.pem ubuntu@$PRIMARY_PUBLIC_IP
```

*For Linux/Mac/Git Bash:*
```bash
# SSH into Primary instance (us-east-1)
ssh -i vpc-peering-demo-east.pem ubuntu@$PRIMARY_PUBLIC_IP
```

*For PuTTY Users (Windows):*
```powershell
# First, convert .pem to .ppk format using PuTTYgen:
# 1. Open PuTTYgen
# 2. Click "Load" and select vpc-peering-demo-east.pem
# 3. Click "Save private key" and save as vpc-peering-demo-east.ppk
# 4. In PuTTY, use ubuntu@<public-ip> and load the .ppk file under SSH > Auth
```

**Common SSH issues and solutions:**

| Issue | Cause | Solution |
|-------|-------|----------|
| `Permission denied (publickey)` | Wrong username or key | Use `ubuntu` not `ec2-user` for Ubuntu AMI |
| `UNPROTECTED PRIVATE KEY FILE!` | Wrong file permissions | Run `icacls /inheritance:r` (Windows) or `chmod 400` (Linux) |
| `Load key: invalid format` | UTF-8 BOM encoding | Recreate key with `-Encoding ASCII` |
| `Connection timed out` | Security group or network | Check SG allows SSH from your IP (0.0.0.0/0) |
| `Connection refused` | Instance still initializing | Wait 2-3 minutes after `terraform apply` |

**Test Secondary Instance:**

*For Windows PowerShell:*
```powershell
# SSH into Secondary instance (us-west-2)
ssh -i .\vpc-peering-demo-west.pem ubuntu@$SECONDARY_PUBLIC_IP
```

*For Linux/Mac/Git Bash:*
```bash
# SSH into Secondary instance (us-west-2)
ssh -i vpc-peering-demo-west.pem ubuntu@$SECONDARY_PUBLIC_IP
```

**Verify you're connected:**
```bash
# Check OS version
cat /etc/os-release

# Check private IP matches Terraform output
hostname -I

# Check Apache is running
systemctl status apache2
```

### Step 19: Test VPC Peering - Ping Test

**From Primary to Secondary:**
```bash
# After SSH'ing into Primary instance
ping -c 4 $SECONDARY_PRIVATE_IP
```

**Expected output:**
```
PING 10.1.1.xxx (10.1.1.xxx) 56(84) bytes of data.
64 bytes from 10.1.1.xxx: icmp_seq=1 ttl=255 time=65.2 ms
64 bytes from 10.1.1.xxx: icmp_seq=2 ttl=255 time=65.1 ms
64 bytes from 10.1.1.xxx: icmp_seq=3 ttl=255 time=65.3 ms
64 bytes from 10.1.1.xxx: icmp_seq=4 ttl=255 time=65.0 ms
```

**From Secondary to Primary:**
```bash
# After SSH'ing into Secondary instance
ping -c 4 $PRIMARY_PRIVATE_IP
```

✅ **Success indicator:** You should see ping responses with ~60-70ms latency (typical for cross-region)

### Step 20: Test HTTP Connectivity

**From Primary to Secondary:**
```bash
# SSH into Primary instance, then:
curl http://$SECONDARY_PRIVATE_IP
```

**Expected output:**
```html
<h1>Secondary VPC Instance - us-west-2</h1>
<p>Private IP: 10.1.1.xxx</p>
```

**From Secondary to Primary:**
```bash
# SSH into Secondary instance, then:
curl http://$PRIMARY_PRIVATE_IP
```

**Expected output:**
```html
<h1>Primary VPC Instance - us-east-1</h1>
<p>Private IP: 10.0.1.xxx</p>
```

✅ **Success indicator:** You can access the web server of each instance from the other VPC using private IPs

---

## Advanced Testing

### Step 21: Network Performance Test

**Install iperf3 on both instances:**
```bash
# On both Primary and Secondary instances
sudo yum install -y iperf3
```

**On Secondary instance (server):**
```bash
# Start iperf3 server
iperf3 -s
```

**On Primary instance (client):**
```bash
# Run bandwidth test
iperf3 -c $SECONDARY_PRIVATE_IP -t 10
```

**Analyze results:**
- Bandwidth: Typical inter-region bandwidth (varies by region pair)
- Latency: Should be consistent with ping results
- Jitter: Should be low (<10ms)

### Step 22: Traceroute Test

**From Primary to Secondary:**
```bash
# Trace the route
traceroute $SECONDARY_PRIVATE_IP
```

**Expected behavior:**
- Should show 1 hop (direct VPC peering connection)
- No intermediate routers (proves traffic goes through peering, not internet)

### Step 23: DNS Resolution Test

**Test private DNS resolution:**
```bash
# On Primary instance
nslookup $SECONDARY_PRIVATE_IP

# Check reverse DNS
dig -x $SECONDARY_PRIVATE_IP
```

### Step 24: Monitor VPC Flow Logs (Optional)

**Enable Flow Logs (if not already):**
```powershell
# Create CloudWatch log group
aws logs create-log-group --log-group-name /aws/vpc/peering-demo --region us-east-1

# Create IAM role for Flow Logs (simplified)
# Note: In production, use proper IAM policies

# Enable Flow Logs on Primary VPC
aws ec2 create-flow-logs `
  --resource-type VPC `
  --resource-ids $PRIMARY_VPC_ID `
  --traffic-type ALL `
  --log-destination-type cloud-watch-logs `
  --log-group-name /aws/vpc/peering-demo `
  --region us-east-1
```

**View Flow Logs:**
```powershell
# After some traffic, check logs
aws logs tail /aws/vpc/peering-demo --follow --region us-east-1
```

### Step 25: Test Security Group Rules

**Verify SSH is blocked from Secondary VPC:**
```bash
# From Secondary instance, try to SSH to Primary
ssh ec2-user@$PRIMARY_PRIVATE_IP
# Should fail - SSH is only allowed from 0.0.0.0/0 (internet), not VPC CIDR
```

**Verify ICMP is allowed:**
```bash
# From Primary instance
ping $SECONDARY_PRIVATE_IP
# Should succeed - ICMP is allowed from VPC CIDR
```

### Step 26: Cost Analysis

**Check estimated costs:**
```powershell
# Use AWS Cost Explorer or CLI
aws ce get-cost-and-usage `
  --time-period Start=2025-11-01,End=2025-11-30 `
  --granularity DAILY `
  --metrics UnblendedCost `
  --filter file://filter.json
```

**Approximate costs (as of Nov 2025):**
- 2x t2.micro instances: ~$0.0116/hour × 2 = ~$0.023/hour
- Data transfer (inter-region): ~$0.02/GB
- VPC Peering: No charge for the connection itself
- **Total estimated: ~$0.60/day if running continuously**

---

## Troubleshooting Guide

### Issue 1: Ping Fails Between VPCs

**Diagnosis:**
```powershell
# Check peering status
aws ec2 describe-vpc-peering-connections --vpc-peering-connection-ids $PEERING_ID --region us-east-1

# Check routes
aws ec2 describe-route-tables --region us-east-1 --filters "Name=vpc-id,Values=$PRIMARY_VPC_ID"
```

**Solutions:**
1. Verify peering connection is "active"
2. Check route tables have correct routes
3. Verify security groups allow ICMP
4. Check NACLs (if modified from default)

### Issue 2: SSH Connection Timeout

**Diagnosis:**
```bash
# Test connectivity
Test-NetConnection -ComputerName $PRIMARY_PUBLIC_IP -Port 22
```

**Solutions:**
1. Verify instance is running: `aws ec2 describe-instances`
2. Check security group allows SSH from your IP
3. Verify key pair matches
4. Confirm instance has public IP

### Issue 3: HTTP Request Fails

**Diagnosis:**
```bash
# Check if Apache is running
systemctl status httpd

# Check port 80 is listening
netstat -tlnp | grep :80
```

**Solutions:**
1. Restart Apache: `sudo systemctl restart httpd`
2. Check security group allows HTTP from peered VPC
3. Verify instance has finished user_data script
4. Check Apache logs: `sudo tail -f /var/log/httpd/error_log`

### Issue 4: Terraform Apply Fails

**Common errors and solutions:**

**"InvalidKeyPair.NotFound":**
```powershell
# Recreate the key pair
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-east-1
```

**"VpcPeeringConnectionAlreadyExists":**
```powershell
# Destroy existing resources
terraform destroy
# Then apply again
terraform apply
```

**"UnauthorizedOperation":**
- Check IAM permissions
- Ensure AWS credentials are valid

---

## Cleanup

### Step 27: Destroy Infrastructure

**Important:** This will delete ALL resources created by Terraform.

```powershell
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy
```

Type `yes` when prompted.

**This will take approximately 2-3 minutes.**

### Step 28: Verify Cleanup

```powershell
# Check VPCs are deleted
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Purpose,Values=VPC-Peering-Demo"
aws ec2 describe-vpcs --region us-west-2 --filters "Name=tag:Purpose,Values=VPC-Peering-Demo"

# Check instances are terminated
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Name,Values=Primary-VPC-Instance"
aws ec2 describe-instances --region us-west-2 --filters "Name=tag:Name,Values=Secondary-VPC-Instance"

# Check peering connection is deleted
aws ec2 describe-vpc-peering-connections --region us-east-1 --filters "Name=status-code,Values=active"
```

### Step 29: Delete Key Pairs (Optional)

**Note:** If you secured your PEM files earlier and get "Access Denied" errors, see [Step 4.1 - Restore Normal Permissions](#step-41-secure-your-pem-key-files-critical) for instructions on how to grant delete permissions.

```powershell
# If you get "Access Denied", restore permissions first:
icacls vpc-peering-demo-east.pem /grant:r "$($env:USERNAME):F"
icacls vpc-peering-demo-west.pem /grant:r "$($env:USERNAME):F"

# Delete key pairs from AWS
aws ec2 delete-key-pair --key-name vpc-peering-demo-east --region us-east-1
aws ec2 delete-key-pair --key-name vpc-peering-demo-west --region us-west-2

# Delete local key files
Remove-Item vpc-peering-demo-east.pem -Force
Remove-Item vpc-peering-demo-west.pem -Force
```

**For Linux/Mac users:**
```bash
# If needed, restore permissions first:
chmod 644 vpc-peering-demo-east.pem vpc-peering-demo-west.pem

# Delete key pairs from AWS
aws ec2 delete-key-pair --key-name vpc-peering-demo-east --region us-east-1
aws ec2 delete-key-pair --key-name vpc-peering-demo-west --region us-west-2

# Delete local key files
rm vpc-peering-demo-east.pem vpc-peering-demo-west.pem
```

### Step 30: Clean Local Files (Optional)

```powershell
# Remove Terraform state files
Remove-Item .terraform -Recurse -Force
Remove-Item terraform.tfstate
Remove-Item terraform.tfstate.backup
Remove-Item .terraform.lock.hcl
Remove-Item terraform.tfvars
Remove-Item deployment-info.txt
```

---

## Success Checklist

Use this checklist to verify your demo build:

- [ ] AWS CLI configured and working
- [ ] Terraform initialized successfully
- [ ] Key pairs created in both regions
- [ ] `terraform.tfvars` configured with key name
- [ ] `terraform apply` completed without errors
- [ ] VPC peering status shows "active"
- [ ] Both instances in "running" state
- [ ] Can SSH into Primary instance
- [ ] Can SSH into Secondary instance
- [ ] Ping works from Primary to Secondary using private IP
- [ ] Ping works from Secondary to Primary using private IP
- [ ] HTTP curl works from Primary to Secondary
- [ ] HTTP curl works from Secondary to Primary
- [ ] Route tables contain peering routes
- [ ] Security groups properly configured
- [ ] All outputs display correct information
- [ ] Documented estimated costs
- [ ] Successfully destroyed all resources

---

## Time Estimates

| Phase | Duration |
|-------|----------|
| Prerequisites Setup | 10-15 minutes |
| Infrastructure Deployment | 5-7 minutes |
| Verification Steps | 10-15 minutes |
| Testing Connectivity | 10-15 minutes |
| Advanced Testing | 20-30 minutes |
| Cleanup | 5 minutes |
| **Total** | **60-87 minutes** |

---

## Key Takeaways

After completing this demo build, you have:

1. ✅ Created a cross-region VPC peering connection
2. ✅ Configured routing for bidirectional traffic
3. ✅ Set up security groups for cross-VPC communication
4. ✅ Deployed EC2 instances in multiple regions
5. ✅ Tested connectivity using ICMP, HTTP, and SSH
6. ✅ Verified VPC peering works with private IPs
7. ✅ Learned to troubleshoot common VPC peering issues
8. ✅ Properly cleaned up all AWS resources

---

## Next Steps

To further enhance your learning:

1. **Add more complexity:**
   - Add private subnets with NAT gateways
   - Implement multiple subnets per VPC
   - Add application load balancers

2. **Implement monitoring:**
   - Set up CloudWatch alarms
   - Enable VPC Flow Logs
   - Create dashboards for metrics

3. **Security enhancements:**
   - Implement Network ACLs
   - Use AWS Systems Manager instead of SSH
   - Add WAF for web applications

4. **Cost optimization:**
   - Use spot instances
   - Implement auto-scaling
   - Schedule instance start/stop

5. **Explore alternatives:**
   - Compare with AWS Transit Gateway
   - Test AWS PrivateLink
   - Implement VPN connections

---

## Additional Resources

- **AWS Documentation:**
  - [VPC Peering Guide](https://docs.aws.amazon.com/vpc/latest/peering/)
  - [VPC Peering Scenarios](https://docs.aws.amazon.com/vpc/latest/peering/peering-scenarios.html)
  - [VPC Peering Limitations](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html#vpc-peering-limitations)

- **Terraform Documentation:**
  - [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [VPC Peering Connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection)

- **Best Practices:**
  - [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
  - [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)

---

## Feedback and Questions

If you encounter any issues or have questions about this demo build:

1. Check the Troubleshooting Guide section
2. Review AWS CloudWatch Logs
3. Verify all prerequisites are met
4. Check AWS service health dashboard

**Happy Learning! 🚀**
