# Quick Reference Guide - Blue-Green Deployment Demo

## Quick Commands

### Package Applications
```powershell
.\package-apps.ps1

or if you are in linux/macOS
.\package-apps.sh 
```

### Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### View Environment URLs
```bash
terraform output blue_environment_url
terraform output green_environment_url
```

### Perform Swap
```powershell
.\swap-environments.ps1
```

### Destroy Resources
```bash
terraform destroy
```

## Expected Timeline

| Task | Duration |
|------|----------|
| Package Applications | 10 seconds |
| Terraform Init | 1 minute |
| Terraform Apply | 15-20 minutes |
| Environment Testing | 5 minutes |
| CNAME Swap | 1-2 minutes |
| Total | ~25-30 minutes |

## Demo Checklist

### Pre-Demo Setup
- [ ] AWS credentials configured
- [ ] Terraform installed
- [ ] AWS CLI installed
- [ ] PowerShell available
- [ ] Run `.\package-apps.ps1`
- [ ] Run `terraform init`
- [ ] Run `terraform apply`
- [ ] Wait for environments to be healthy
- [ ] Note down both environment URLs

### During Demo
- [ ] Explain blue-green deployment concept
- [ ] Show Blue environment (v1.0) in browser
- [ ] Show Green environment (v2.0) in browser
- [ ] Explain the differences
- [ ] Run `.\swap-environments.ps1`
- [ ] Explain what's happening during swap
- [ ] Wait for swap to complete (1-2 min)
- [ ] Refresh Blue URL - now shows v2.0
- [ ] Refresh Green URL - now shows v1.0
- [ ] Explain rollback capability

### Post-Demo Cleanup
- [ ] Run `terraform destroy`
- [ ] Verify all resources deleted in AWS Console
- [ ] Check no unexpected charges

## Key Talking Points

1. **What is Blue-Green Deployment?**
   - Two identical environments
   - Blue = Current production
   - Green = New version staging
   - Instant traffic switch

2. **Benefits**
   - Zero downtime
   - Easy rollback
   - Safe testing
   - Production parity

3. **AWS vs Azure**
   - AWS: Elastic Beanstalk Environments
   - Azure: App Service Deployment Slots
   - Both achieve same goal
   - Slightly different mechanisms

4. **When to Use**
   - Critical production applications
   - Need for instant rollback
   - Zero downtime requirement
   - Safe deployment testing

## Common Issues & Solutions

### Issue: Terraform Apply Fails
**Solution:** Check AWS credentials and permissions

### Issue: Environments Stay "Launching"
**Solution:** Wait 15-20 minutes, check CloudWatch logs

### Issue: Swap Command Fails
**Solution:** Ensure both environments are "Green" health status

### Issue: Application Not Loading
**Solution:** Check security groups, verify port 8080

## Demo Script

### Introduction (2 minutes)
"Today we're demonstrating blue-green deployment on AWS using Elastic Beanstalk. This is AWS's equivalent to Azure App Service deployment slots."

### Setup Overview (1 minute)
"We have two identical environments:
- Blue running Version 1.0
- Green running Version 2.0"

### Show Blue Environment (1 minute)
"This is our current production environment..."
[Open Blue URL in browser]

### Show Green Environment (1 minute)
"This is our new version in staging..."
[Open Green URL in browser]

### Perform Swap (3 minutes)
"Now let's swap these environments with zero downtime..."
[Run swap script]
"The swap takes 1-2 minutes..."

### Verify Swap (2 minutes)
"As you can see, production now shows version 2.0..."
[Refresh browsers]

### Explain Rollback (1 minute)
"If there's an issue, we simply swap again to rollback instantly!"

## URLs to Bookmark During Demo

```
Blue URL: _________________________________

Green URL: ________________________________

AWS Console: https://console.aws.amazon.com/elasticbeanstalk

Terraform Cloud/State: ____________________
```

## Cost Reminder

**Running Cost:** ~$2-3 per day
**Remember:** Destroy after demo to avoid charges!

```bash
terraform destroy -auto-approve
```

## Additional Resources

- Architecture Diagram: `ARCHITECTURE.md`
- Full Documentation: `README.md`
- AWS EB Docs: https://docs.aws.amazon.com/elasticbeanstalk/

## Troubleshooting Commands

```bash
# Check environment health
aws elasticbeanstalk describe-environment-health \
  --environment-name <env-name> \
  --attribute-names All \
  --region us-east-1

# View recent events
aws elasticbeanstalk describe-events \
  --environment-name <env-name> \
  --max-records 20 \
  --region us-east-1

# Check Terraform state
terraform show

# View all outputs
terraform output
```

## Notes Section

Use this space for your personal notes during the demo:

---
