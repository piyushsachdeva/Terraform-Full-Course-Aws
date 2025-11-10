# VPC Peering Demo - Quick Start Guide

Get your VPC peering demo up and running in **5 minutes**!

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.6.0 installed
- SSH key pair (optional, for instance access)

## Quick Deploy Steps

### 1. Clone & Navigate
```powershell
cd c:\repos\Terraform-Full-Course-Aws\lessons\day15
```

### 2. Create SSH Key Pairs (Optional)
```powershell
# For us-east-1
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-east-1 --query 'KeyMaterial' --output text | Out-File -FilePath vpc-peering-demo-east.pem -Encoding ASCII

# For us-west-2
aws ec2 create-key-pair --key-name vpc-peering-demo --region us-west-2 --query 'KeyMaterial' --output text | Out-File -FilePath vpc-peering-demo-west.pem -Encoding ASCII
```

### 3. Configure Variables
```powershell
# Copy example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit with your key name (or leave empty to skip SSH)
notepad terraform.tfvars
```

Update the `key_name` value:
```hcl
key_name = "vpc-peering-demo"  # or leave as "" to skip SSH
```

### 4. Deploy Infrastructure
```powershell
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy (takes ~3-5 minutes)
terraform apply -auto-approve
```

### 5. Get Outputs
```powershell
# View all outputs
terraform output

# Save to file
terraform output | Out-File -FilePath deployment-info.txt
```

## Quick Test

### Test Connectivity
```powershell
# Get IPs
$PRIMARY_IP = (terraform output -raw primary_instance_public_ip)
$SECONDARY_PRIVATE_IP = (terraform output -raw secondary_instance_private_ip)

# SSH into primary instance
ssh -i vpc-peering-demo-east.pem ec2-user@$PRIMARY_IP

# Once logged in, ping the secondary instance
ping $SECONDARY_PRIVATE_IP
```

Expected: Successful ping responses (60-70ms latency for cross-region).

## Quick Cleanup

```powershell
# Destroy all resources
terraform destroy -auto-approve
```

## Troubleshooting

### Issue: "InvalidKeyPair.NotFound"
**Solution:** Create the key pair or set `key_name = ""` in `terraform.tfvars`

### Issue: Backend initialization error
**Solution:** Comment out the `backend "s3"` block in `backend.tf` for local development

### Issue: Permission denied
**Solution:** Check AWS credentials with `aws sts get-caller-identity`

## What Gets Created

- ✅ 2 VPCs (us-east-1 & us-west-2)
- ✅ 2 Public subnets
- ✅ 2 Internet gateways
- ✅ 1 VPC peering connection
- ✅ 2 Route tables with peering routes
- ✅ 2 Security groups
- ✅ 2 EC2 instances (t2.micro)

## Estimated Cost

~$0.60/day if left running (2x t2.micro + data transfer)

## Next Steps

- 📖 Read [DEMO-BUILD.md](DEMO-BUILD.md) for detailed walkthrough
- 📊 Review [FILE-STRUCTURE.md](FILE-STRUCTURE.md) for architecture
- 🔧 Check [README.md](README.md) for comprehensive guide

**Happy Terraforming! 🚀**
