# Day 17: AWS Elastic Beanstalk Blue-Green Deployment Demo

This demo replicates the Azure App Service deployment slot functionality using **AWS Elastic Beanstalk** to achieve zero-downtime deployments through blue-green deployment strategy.

## 🎯 What This Demo Does

This Terraform project creates:
- **Blue Environment** (Production) - Running Application v1.0
- **Green Environment** (Staging) - Running Application v2.0
- Complete infrastructure with load balancers, auto-scaling, and health checks
- Ability to instantly swap traffic between environments with zero downtime

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                  Elastic Beanstalk Application              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────┐      ┌──────────────────────┐   │
│  │  Blue Environment    │      │  Green Environment   │   │
│  │  (Production)        │      │  (Staging)           │   │
│  ├──────────────────────┤      ├──────────────────────┤   │
│  │  Version 1.0         │      │  Version 2.0         │   │
│  │  Load Balancer       │      │  Load Balancer       │   │
│  │  Auto Scaling        │      │  Auto Scaling        │   │
│  │  Health Checks       │      │  Health Checks       │   │
│  │                      │      │                      │   │
│  │  URL: my-app-blue... │      │  URL: my-app-green..│   │
│  └──────────────────────┘      └──────────────────────┘   │
│           │                              │                 │
│           └──────────────┬───────────────┘                 │
│                          │                                 │
│                 CNAME Swap (Instant)                       │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** (>= 1.0) installed
3. **AWS CLI** configured with credentials
4. **PowerShell** (for packaging scripts)
5. **Node.js** (optional, for local testing)

## 🚀 Quick Start

### Step 1: Package the Applications

First, package both versions of the application:

```powershell
.\package-apps.ps1
```

This creates:
- `app-v1/app-v1.zip` - Version 1.0 (Blue)
- `app-v2/app-v2.zip` - Version 2.0 (Green)

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

### Step 4: Deploy Infrastructure

```bash
terraform apply
```

⏳ **Note:** The deployment takes approximately 15-20 minutes as Elastic Beanstalk provisions:
- EC2 instances
- Application Load Balancers
- Auto Scaling Groups
- Security Groups
- CloudWatch monitoring

### Step 5: View the Outputs

After deployment completes, Terraform will display:

```bash
terraform output instructions
```

You'll see the URLs for both environments:
- **Blue Environment (Production):** `http://my-app-bluegreen-blue-xxxxxx.elasticbeanstalk.com`
- **Green Environment (Staging):** `http://my-app-bluegreen-green-xxxxxx.elasticbeanstalk.com`

## 🔵 Testing the Blue Environment (Production - v1.0)

Visit the Blue environment URL. You should see:
- **Version 1.0** displayed prominently
- **Blue color scheme**
- **"PRODUCTION" badge**
- Basic feature set

## 🟢 Testing the Green Environment (Staging - v2.0)

Visit the Green environment URL. You should see:
- **Version 2.0** displayed prominently
- **Green color scheme**
- **"STAGING" badge**
- New features listed:
  - Refreshed UI with modern design
  - Improved performance
  - Enhanced security features
  - Better analytics tracking
  - Critical bug fixes

## 🔄 Performing the Blue-Green Swap

Once you've verified the Green environment is working correctly, perform the swap:

### Option 1: Using the PowerShell Script (Recommended)

```powershell
.\swap-environments.ps1
```

The script will:
1. Automatically read environment names from Terraform
2. Ask for confirmation
3. Perform the CNAME swap
4. Display status and next steps

### Option 2: Using AWS CLI Directly

```bash
aws elasticbeanstalk swap-environment-cnames \
  --source-environment-name my-app-bluegreen-blue \
  --destination-environment-name my-app-bluegreen-green \
  --region us-east-1
```

### Option 3: Using AWS Console (Step-by-Step with Screenshots)

**Step 1:** Open the AWS Console
- Navigate to [AWS Elastic Beanstalk Console](https://console.aws.amazon.com/elasticbeanstalk)
- Ensure you're in the correct region (us-east-1 by default)

**Step 2:** Select Your Application
- In the Applications list, click on **my-app-bluegreen**
- You'll see both environments listed (Blue and Green)

**Step 3:** Choose an Environment to Swap
- Click on either the **Blue** or **Green** environment name
- (You can start from either environment - the result is the same)

**Step 4:** Access the Swap Action
- Click the **Actions** button (top right)
- From the dropdown menu, select **Swap environment URLs**

**Step 5:** Select the Target Environment
- A dialog will appear asking which environment to swap with
- Select the other environment from the dropdown
  - If you started from Blue, select Green
  - If you started from Green, select Blue

**Step 6:** Confirm the Swap
- Review the warning message about traffic redirection
- Click the **Swap** button to confirm

**Step 7:** Monitor the Swap
- The environments will show "Updating" status
- Wait 1-2 minutes for the swap to complete
- Both environments will return to "Ok" (green) status

**Step 8:** Verify Success
- Note that the **URLs have been swapped**
- The environment names stay the same, but the URLs are exchanged
- Visit both URLs to confirm the swap worked

## ✅ Verifying the Swap

After the swap completes (1-2 minutes), verify:

1. **Blue URL now shows v2.0:**
   ```
   Visit: <blue-url>
   Expected: "Welcome to Version 2.0 - Green Environment"
   ```

2. **Green URL now shows v1.0:**
   ```
   Visit: <green-url>
   Expected: "Welcome to Version 1.0 - Blue Environment"
   ```

3. **Zero Downtime:** Your production traffic seamlessly moved from v1.0 to v2.0!

## 🔙 Rolling Back

If you need to rollback to the previous version:

```powershell
# Simply run the swap again!
.\swap-environments.ps1
```

The swap is instant and bidirectional - the previous production environment is still running the old version.

## 📊 Key Features Demonstrated

### 1. **Zero-Downtime Deployment**
- Traffic switches instantly at the DNS level
- No service interruption
- Users experience seamless transition

### 2. **Easy Rollback**
- Previous version still running in the other environment
- Instant rollback by swapping again
- No need to redeploy

### 3. **Safe Testing**
- Test new version in production-like environment
- Same infrastructure configuration
- Isolated from production traffic

### 4. **Production Parity**
- Both environments identical
- Same instance types, scaling, and configuration
- Eliminates "works on staging" issues

## 🏷️ Resource Tagging

All resources are tagged with:
- `Project: BlueGreenDeployment`
- `Environment: Demo`
- `ManagedBy: Terraform`

## 💰 Cost Considerations

This demo creates:
- 2 Application Load Balancers (~$16/month each)
- 2-4 EC2 instances (depending on auto-scaling)
- S3 bucket for application versions
- CloudWatch monitoring

**Estimated Monthly Cost:** $50-100 USD (depending on instance types and usage)

**To minimize costs:**
- Use `t3.micro` instances (default)
- Destroy resources when not in use: `terraform destroy`
- Set appropriate auto-scaling limits

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning:** This will delete:
- Both Elastic Beanstalk environments
- Application Load Balancers
- EC2 instances
- S3 bucket (if empty)
- All associated resources

## 📝 Customization

### Change AWS Region

Edit `variables.tf`:
```hcl
variable "aws_region" {
  default = "us-west-2"  # Change to your preferred region
}
```

### Change Instance Type

Edit `variables.tf`:
```hcl
variable "instance_type" {
  default = "t3.small"  # Upgrade for better performance
}
```

### Modify Application Name

Edit `variables.tf`:
```hcl
variable "app_name" {
  default = "my-custom-app"
}
```

## 🔍 Troubleshooting

### Environment Health Issues

Check environment health:
```bash
aws elasticbeanstalk describe-environment-health \
  --environment-name my-app-bluegreen-blue \
  --attribute-names All \
  --region us-east-1
```

### Deployment Failures

View recent events:
```bash
aws elasticbeanstalk describe-events \
  --environment-name my-app-bluegreen-blue \
  --max-records 50 \
  --region us-east-1
```

### Application Logs

Access logs through:
1. AWS Console → Elastic Beanstalk → Environment → Logs
2. Or request logs via CLI:
```bash
aws elasticbeanstalk request-environment-info \
  --environment-name my-app-bluegreen-blue \
  --info-type tail \
  --region us-east-1
```

## 🔗 Comparison with Azure

| Feature | Azure App Service | AWS Elastic Beanstalk |
|---------|------------------|----------------------|
| Service Type | PaaS | PaaS |
| Deployment Slots | Native feature | Separate Environments |
| Swap Mechanism | Slot Swap | CNAME Swap |
| Swap Speed | Instant | 1-2 minutes |
| Rollback | One-click swap | One-click swap |
| Cost | Per slot | Per environment |

## 📚 Learning Resources

- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [Blue-Green Deployment Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🎓 What You've Learned

✅ How to implement blue-green deployments on AWS  
✅ Elastic Beanstalk environment management  
✅ Zero-downtime deployment strategies  
✅ Infrastructure as Code with Terraform  
✅ AWS CLI for environment swapping  
✅ Production-safe deployment practices  

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This project is provided as-is for educational purposes.

---

**Happy Deploying! 🚀**
