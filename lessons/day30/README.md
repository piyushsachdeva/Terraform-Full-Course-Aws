# 🔍 Terraform Drift Detection & Auto-Remediation

Automated infrastructure drift detection using GitHub Actions, Terraform, and AWS.

[![Terraform](https://img.shields.io/badge/Terraform-1.10.3-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)

## 📖 Overview

Detects and automatically fixes AWS infrastructure drift. Deploys VPC, ALB, ASG, and S3 with continuous monitoring.

**Key Features**: ⏰ Scheduled checks (every minute) • 🔄 Auto-remediation • 🌍 Multi-environment • 📊 Notifications

## 🚀 Quick Start

```bash
# 1. Clone & setup backend
git clone <repository-url>
./scripts/setup-backend.sh my-terraform-state-bucket us-east-1

# 2. Update backend-dev.hcl / backend-prod.hcl
# 3. Add GitHub Secrets: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, SLACK_WEBHOOK_URL (optional)
# 4. Deploy
terraform init -backend-config="backend-dev.hcl"
terraform apply
```

## 📁 Project Structure

```
terraform-drift-detection/
├── scripts/ (setup-backend.sh, user_data.sh)
├── main.tf, vpc.tf, security_groups.tf, alb.tf, asg.tf, s3.tf
├── variables.tf, outputs.tf, backend.tf
└── backend-dev.hcl, backend-prod.hcl
```

The Day 30 GitHub workflows are in the repository-root `.github/workflows/` directory.

## 🔄 How It Works

1. GitHub Actions triggers every minute
2. Terraform plan compares actual vs. desired state
3. If drift detected (exit code 2): auto-apply fixes
4. Create/close GitHub issues and Slack notifications

## 🧪 Test Drift

```bash
# Manually modify a resource
aws ec2 create-tags --resources i-xxx --tags Key=Test,Value=val

# Workflow detects and fixes automatically
```

## 🔧 Configuration

**Change detection frequency** in the repository-root `.github/workflows/drift_detection.yml`:

```yaml
schedule:
  - cron: "*/5 * * * *"  # Every 5 minutes
```

## 🐛 Troubleshooting

| Issue | Fix |
|-------|-----|
| Workflow not running | Enable workflow in Actions tab |
| Apply fails | Check AWS credentials & IAM permissions |
| State lock error | `terraform force-unlock <LOCK_ID>` |

## 🧹 Cleanup

```bash
terraform destroy -auto-approve
aws s3 rm s3://your-bucket --recursive && aws s3api delete-bucket --bucket your-bucket
```

## 📚 Resources

- [Demo Guide](DEMO_GUIDE.md)
- [Terraform Docs](https://www.terraform.io/docs)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Author**: [@itsBaivab](https://github.com/itsBaivab)  
**License**: MIT
