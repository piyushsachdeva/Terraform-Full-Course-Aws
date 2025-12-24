# Terraform Drift Detection Demo Guide

Complete walkthrough for demonstrating automated Terraform drift detection, auto-remediation, and infrastructure management across dev and production environments.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Overview](#project-overview)
3. [Initial Setup](#initial-setup)
4. [Deploying Infrastructure](#deploying-infrastructure)
5. [Testing Drift Detection](#testing-drift-detection)
6. [Understanding the Workflows](#understanding-the-workflows)
7. [Cleanup](#cleanup)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts & Tools

- ✅ GitHub account with repository access
- ✅ AWS account with admin access
- ✅ Terraform CLI installed locally (optional, for manual testing)
- ✅ Git CLI installed
- ✅ Slack workspace (optional, for notifications)

### AWS IAM Permissions Required

Your AWS credentials need permissions for:

- EC2 (VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables)
- Auto Scaling Groups
- Application Load Balancer
- S3 Buckets
- Security Groups

---

## Project Overview

### Infrastructure Components

This demo creates a complete web application infrastructure:

```
┌─────────────────────────────────────────┐
│           Application Load Balancer      │
└─────────────┬───────────────────────────┘
              │
    ┌─────────┴─────────┐
    │                   │
┌───▼────┐         ┌────▼───┐
│  EC2   │         │  EC2   │
│Instance│         │Instance│
└────────┘         └────────┘
    │                   │
    └─────────┬─────────┘
              │
     ┌────────▼────────┐
     │   VPC Network    │
     │  - Public Subnet │
     │  - Private Subnet│
     │  - NAT Gateway   │
     └──────────────────┘
```

**Resources Created:**

- VPC with public/private subnets across 2 AZs
- Internet Gateway and NAT Gateway
- Application Load Balancer
- Auto Scaling Group (min: 1, max: 3 instances)
- S3 bucket for application data
- Security groups for ALB and EC2

### Environments

| Environment | Branch | Purpose | Drift Detection |
|-------------|--------|---------|-----------------|
| **Dev** | `dev` | Development/testing | ⚠️ Manual trigger only |
| **Prod** | `main` | Production | ✅ Enabled (every 1 min + auto-fix) |

### Workflows

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| **CI/CD** | `terraform.yml` | Push to main/dev | Deploy infrastructure |
| **Drift Detection** | `drift_detection.yml` | Every 1 minute (prod only) + Manual | Detect & auto-fix drift |
| **Destroy** | `destroy.yml` | Manual trigger | Safely destroy infrastructure |

---

## Initial Setup

### Step 1: Fork/Clone Repository

```bash
# Clone the repository
git clone https://github.com/itsBaivab/terraform-drift-detection.git
cd terraform-drift-detection

# Create dev branch
git checkout -b dev
git push origin dev
```

### Step 2: Verify Remote State Backend

**✅ Backend Already Configured!**

The project is pre-configured to use S3 for remote state storage:

- **S3 Bucket:** `techtutorialswithpiyush-terraform-state`
- **Dev State:** `dev/terraform.tfstate`
- **Prod State:** `prod/terraform.tfstate`
- **Locking:** S3 native locking (Terraform 1.10.3)

**Backend Configuration:**

```hcl
# backend-dev.hcl
bucket       = "techtutorialswithpiyush-terraform-state"
key          = "dev/terraform.tfstate"
region       = "us-east-1"
use_lockfile = true  # S3 native locking
encrypt      = true

# backend-prod.hcl
bucket       = "techtutorialswithpiyush-terraform-state"
key          = "prod/terraform.tfstate"
region       = "us-east-1"
use_lockfile = true
encrypt      = true
```

**S3 Native State Locking:**

- ✅ Uses Terraform 1.10.3 feature `use_lockfile = true`
- ✅ Creates `.tflock` files in S3 for state locking
- ✅ No DynamoDB needed - simpler and cheaper
- ✅ Lock files automatically created/deleted during operations

**Verify S3 Bucket Access:**

```bash
# Check if you have access to the bucket
aws s3 ls s3://techtutorialswithpiyush-terraform-state/

# Should show dev/ and prod/ folders after first deployment
```

### Step 3: Configure AWS Credentials

1. **Create IAM User** (or use existing)
   - Go to AWS Console → IAM → Users → Create User
   - Attach policy: `AdministratorAccess` (or custom policy with required permissions)
   - Create Access Key → Store securely

2. **Add GitHub Secrets**
   - Go to repository → Settings → Secrets and variables → Actions → New repository secret

   Add these secrets:

   | Secret Name | Value | Required |
   |-------------|-------|----------|
   | `AWS_ACCESS_KEY_ID` | Your AWS access key | ✅ Yes |
   | `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | ✅ Yes |
   | `SLACK_WEBHOOK_URL` | Slack webhook URL | ⚠️ Optional |

   **Note:** The S3 bucket name (`techtutorialswithpiyush-terraform-state`) is hardcoded in the backend configuration files and doesn't need to be a secret.

### Step 4: Configure GitHub Environments

Create environments for approval gates (optional but recommended):

1. Go to Settings → Environments → New environment
2. Create two environments:
   - **dev** - No protection rules needed
   - **prod** - Add protection rules:
     - ✅ Required reviewers: Add yourself
     - ✅ Wait timer: 0 minutes

### Step 5: Create Slack Webhook (Optional)

If you want Slack notifications:

1. Go to <https://api.slack.com/messaging/webhooks>
2. Create a new webhook for your workspace
3. Copy the webhook URL
4. Add as `SLACK_WEBHOOK_URL` secret in GitHub

---

## Deploying Infrastructure

### Deploy Development Environment

1. **Create/Push to dev branch:**

   ```bash
   git checkout dev
   # Make any changes if needed
   git add .
   git commit -m "Deploy dev environment"
   git push origin dev
   ```

2. **Monitor Deployment:**
   - Go to Actions tab in GitHub
   - Watch "Terraform CI/CD" workflow
   - Plan job runs first
   - Apply job deploys infrastructure

3. **Verify Deployment:**
   - Check workflow summary for outputs
   - Or manually check AWS Console:
     - EC2 → Load Balancers
     - EC2 → Auto Scaling Groups
     - VPC → Your VPCs

### Deploy Production Environment

1. **Merge dev to main:**

   ```bash
   git checkout main
   git merge dev
   git push origin main
   ```

2. **Approve Deployment** (if using environment protection):
   - Go to Actions → Workflow run
   - Review and approve the deployment

3. **Verify Production:**
   - Same verification steps as dev
   - Note: This environment will have drift detection enabled

---

## Testing Drift Detection

### Understanding Drift Detection

Drift occurs when:

- Manual changes via AWS Console
- Changes by other automation/scripts
- External modifications to infrastructure

### Test Scenario 1: Manual Tag Modification

**Simulate drift by modifying a resource tag:**

```bash
# Get the ALB name from Terraform outputs
# In GitHub Actions output, or run locally:
terraform output alb_dns_name

# Manually add a tag via AWS CLI
aws elbv2 add-tags \
  --resource-arns arn:aws:elasticloadbalancing:us-east-1:ACCOUNT_ID:loadbalancer/app/YOUR-ALB-NAME \
  --tags Key=ManualTag,Value=DriftTest
```

Or via AWS Console:

1. EC2 → Load Balancers
2. Select your ALB
3. Tags → Manage tags
4. Add tag: `ManualTag=DriftTest`

**What happens:**

1. Next day at 8 AM UTC (or trigger manually), drift detection runs
2. Detects the unexpected tag
3. Creates GitHub issue: "🚨 Terraform Drift Detected"
4. Automatically runs `terraform apply` to remove the tag
5. Sends Slack notification (if configured)
6. Closes issue once fixed

### Test Scenario 2: Manual Instance Termination

**More dramatic drift test:**

```bash
# List ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names YOUR-ASG-NAME

# Terminate one instance (ASG will recreate it)
aws ec2 terminate-instances --instance-ids i-xxxxx
```

**What happens:**

- ASG automatically recreates the instance (within minutes)
- Drift detection may not catch this (depends on timing)
- Good test of ASG self-healing

### Test Scenario 3: Security Group Rule Change (Recommended for Demo)

**Simulate unauthorized SSH access by adding a security group rule:**

**Step 1: Get your security group ID**

```bash
# Find the ALB security group
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=*alb*" \
  --query "SecurityGroups[0].GroupId" \
  --output text
```

**Step 2: Add unauthorized SSH rule**

```bash
# Add dangerous SSH rule allowing access from anywhere
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --description "Unauthorized SSH access"
```

**Or via AWS Console:**

1. EC2 → Security Groups
2. Find your ALB security group (e.g., `dev-alb-sg`)
3. Inbound rules → Edit inbound rules
4. Add rule:
   - **Type:** SSH
   - **Protocol:** TCP
   - **Port:** 22
   - **Source:** 0.0.0.0/0 (Anywhere IPv4)
   - **Description:** Unauthorized SSH access
5. Save rules

**What happens next:**

1. **Within 1 minute:** Drift detection workflow runs automatically
2. **Detection:** Identifies the unauthorized SSH rule
3. **GitHub Issue:** Creates issue `🚨 Terraform Drift Detected [dev]`
4. **Auto-Remediation:** Automatically removes the dangerous SSH rule
5. **Slack Alert:** Sends notification (if configured)
6. **Issue Closed:** Marks drift as remediated

**Why this is the best demo:**

- ✅ Represents real security risk
- ✅ Easy to verify in AWS Console
- ✅ Shows immediate automated response
- ✅ Demonstrates infrastructure security enforcement
- ✅ Clear visual confirmation when rule is removed

### Manual Drift Detection Trigger

Don't want to wait for the automatic schedule (runs every minute)?

1. Go to Actions → "Terraform Drift Detection"
2. Click "Run workflow" → Select branch (main or dev)
3. Click "Run workflow" button
4. Watch it detect and fix drift in real-time

**Note:** Drift detection runs automatically every minute, so you'll see results very quickly after making changes!

---

## Understanding the Workflows

### Workflow 1: Terraform CI/CD (`terraform.yml`)

**Triggers:**

- Push to `main` or `dev` branches
- Pull request to `main` or `dev`

**Jobs:**

#### Plan Job (Always runs)

- ✅ Checks out code
- ✅ Determines environment (dev or prod)
- ✅ Runs `terraform plan`
- ✅ Comments plan on PR
- ✅ Uploads plan artifact

#### Apply Job (Only on push)

- ✅ Downloads plan artifact
- ✅ Runs `terraform apply`
- ✅ Outputs infrastructure info

**Environment Variable Logic:**

```yaml
main branch → prod environment
dev branch  → dev environment
```

### Workflow 2: Drift Detection (`drift_detection.yml`)

**Triggers:**

- **Scheduled:** Every 1 minute (automatic, prod only)
- **Manual:** Via GitHub Actions UI (both dev and prod)

**Important:** Scheduled runs only execute on the default branch (main/prod). Dev environment requires manual trigger.

**Flow:**

```
1. terraform plan -detailed-exitcode
2. Exit code 2? → Drift detected
3. Create/update GitHub issue
4. Run terraform apply -auto-approve
5. Send Slack notification
6. Close issue on success
```

**Exit Codes:**

- `0` = No drift (closes any open drift issues)
- `1` = Error (fails workflow)
- `2` = Drift detected (triggers auto-fix)

### GitHub Issues Integration - How It Helps

The drift detection workflow automatically creates and manages GitHub Issues to provide visibility, tracking, and audit trails for infrastructure drift. This integration is crucial for team collaboration and compliance.

#### Why GitHub Issues for Drift Tracking?

**1. Centralized Visibility**

- All drift incidents visible in one place
- Team members can see active infrastructure problems
- No need to check Actions tab constantly
- Email/mobile notifications for new issues

**2. Audit Trail & Compliance**

- Permanent record of all drift events
- Timestamps for detection and resolution
- Shows what changed and when
- Useful for security audits and compliance reports

**3. Team Collaboration**

- Tag team members for critical drift
- Discuss root causes in comments
- Document manual intervention if needed
- Share knowledge about recurring drift patterns

**4. Automated Issue Lifecycle**

- Created automatically when drift detected
- Updated with new drift information
- Closed automatically when fixed
- Labels for easy filtering (environment, auto-fix status)

#### Issue Lifecycle Example

**Phase 1: Drift Detection**

```
Drift detected at 2:34 PM
    ↓
Issue Created: "🚨 Terraform Drift Detected [prod]"
    ↓
Labels: drift-detection, auto-fix, prod
Status: Open
```

**Issue Content Includes:**

```markdown
### Drift Detected & Auto-Remediation Started

Terraform has detected changes in the infrastructure that are not in the state file.
Auto-fix will be applied automatically.

<details>
<summary>Show Plan</summary>

```terraform
~ resource "aws_security_group" "alb" {
    ~ ingress {
        + cidr_blocks = ["0.0.0.0/0"]  # Unauthorized change!
        + from_port   = 22
      }
  }
```

</details>

Action: Auto-applying changes...
Environment: prod
Workflow Run: #42
Detected at: 2025-12-24 14:34:12 UTC

```

**Phase 2: Auto-Remediation Success**
```

terraform apply completes successfully
    ↓
Comment added: "✅ Drift has been automatically remediated."
    ↓
Status: Closed

```

**Phase 3: Recurring Drift (Same Issue)**
```

If drift detected again within hour:
    ↓
Adds comment to existing issue instead of creating new one
    ↓
Prevents issue spam

```

#### Issue Management Flow

```

Drift Detected
    ↓
Check for existing open drift issue for environment
    │
    ├─ Issue exists?
    │   ├─ YES → Add comment with new drift details
    │   └─ NO → Create new issue
    │
    ↓
Auto-remediation attempt
    │
    ├─ Success?
    │   ├─ YES → Close issue with success message
    │   └─ NO → Keep open + add failure comment
    │
    ↓
No Drift Detected
    ↓
Find all open drift issues for environment
    ↓
Close with "✅ Infrastructure in sync" message

```

#### Real-World Usage Scenarios

**Scenario 1: Unauthorized Security Group Change**
```

Time: 14:34 - Someone adds SSH rule from 0.0.0.0/0
Time: 14:35 - Drift detected, issue created
Time: 14:35 - Auto-fix removes rule, issue closed
Time: 14:36 - Team reviews issue to understand what happened

```

**Scenario 2: Manual Fix Required**
```

Time: 09:15 - Drift detected (missing IAM permissions)
Time: 09:16 - Issue created
Time: 09:16 - Auto-fix fails (permission error)
Time: 09:17 - Issue stays open with failure details
Time: 09:30 - DevOps sees open issue, investigates
Time: 09:45 - Manual fix applied, issue manually closed

```

**Scenario 3: Recurring Drift Pattern**
```

Week 1: 3 drift issues for same security group
    ↓
Team reviews GitHub Issues
    ↓
Identifies: Automated scanner is modifying rules
    ↓
Root cause: Scanner should be excluded
    ↓
Fix implemented: Update scanner configuration
    ↓
No more drift issues

```

#### Filtering & Searching Issues

**Find all drift issues:**
```

Label: drift-detection

```

**Find production drift only:**
```

Label: prod is:open

```

**Find failed auto-fixes:**
```

Label: drift-detection "Auto-Fix Failed"

```

**Find issues from specific date:**
```

Label: drift-detection created:>2025-12-20

```

#### Benefits for Different Roles

**DevOps Engineers:**
- Quick overview of infrastructure health
- Historical drift patterns
- Performance metrics (how often drift occurs)
- Root cause analysis data

**Security Teams:**
- Unauthorized changes immediately visible
- Audit trail for compliance
- Evidence of automated remediation
- Security incident documentation

**Managers:**
- Infrastructure stability metrics
- Team response times
- Compliance documentation
- Cost of manual changes (time spent)

**Developers:**
- Understand when their changes cause drift
- See impact of manual testing changes
- Learn infrastructure best practices
- Collaborate on solutions

#### Integration with Slack

When combined with Slack notifications, the workflow provides:

**GitHub Issues:** Long-term record, searchable, detailed
**Slack:** Real-time alerts, immediate visibility, team awareness

```

Drift Event
    ↓
    ├─ GitHub Issue (persistent record)
    └─ Slack Message (immediate alert)

```

**Example Slack Message:**
```

✅ Terraform Drift Auto-Fixed

Repository: terraform-drift-detection
Branch: main
Environment: prod
Workflow: View Run

Terraform has automatically applied changes to remediate infrastructure drift.
See issue #42 for details.

```

#### Customizing Issue Behavior

You can modify the workflow to customize issue creation:

**Change issue title format:**
```javascript
title: `⚠️ Infrastructure Drift - ${env.toUpperCase()} - ${timestamp}`
```

**Add more labels:**

```javascript
labels: ['drift-detection', 'auto-fix', env, 'urgent', 'security']
```

**Assign to specific team:**

```javascript
assignees: ['devops-team', 'security-lead']
```

**Add project board:**

```javascript
// Automatically add to project board
await github.rest.projects.createCard({
  column_id: PROJECT_COLUMN_ID,
  content_id: issue.data.id,
  content_type: 'Issue'
});
```

#### Metrics from GitHub Issues

You can analyze drift patterns using GitHub Issues API:

```bash
# Count drift events per month
gh issue list --label drift-detection --state all --json createdAt

# Average time to resolution
gh issue list --label drift-detection --state closed --json createdAt,closedAt

# Most common drift types (from issue body analysis)
gh issue list --label drift-detection --json body
```

### Workflow 3: Destroy (`destroy.yml`)

**Triggers:**

- Manual only (workflow_dispatch)

**Safety Features:**

- ✅ Must type "DESTROY" exactly
- ✅ Environment selection (dev or prod)
- ✅ Requires environment approval (if configured)
- ✅ Creates issue tracking destruction

**Usage:**

1. Actions → "Terraform Destroy"
2. Run workflow
3. Select environment: dev or prod
4. Type "DESTROY" in confirmation field
5. Run workflow
6. Approve (if prod environment protection enabled)

---

## Cleanup

### Important: Backend State Files

Before destroying infrastructure, note that state files in S3 will remain. You can:

- Keep them for audit/history
- Delete them after infrastructure is destroyed
- The S3 bucket and DynamoDB table are NOT managed by Terraform

### Method 1: Using Destroy Workflow (Recommended)

**Destroy Dev Environment:**

1. Actions → "Terraform Destroy"
2. Run workflow
   - Environment: `dev`
   - Confirmation: `DESTROY`
3. Wait for completion

**Destroy Prod Environment:**

1. Actions → "Terraform Destroy"
2. Run workflow
   - Environment: `prod`
   - Confirmation: `DESTROY`
3. Approve the deployment
4. Wait for completion

### Method 2: Manual Terraform Destroy

If workflows fail:

```bash
# Clone repo locally
git clone https://github.com/itsBaivab/terraform-drift-detection.git
cd terraform-drift-detection

# Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"

# Initialize and destroy
terraform init
terraform destroy -auto-approve
```

### Method 3: Manual AWS Cleanup

If Terraform fails, manually delete in AWS Console:

**Order matters! Delete in this order:**

1. Auto Scaling Group (wait for instances to terminate)
2. Target Groups
3. Load Balancer
4. Launch Template
5. NAT Gateway (wait ~5 min for release)
6. Elastic IPs
7. Internet Gateway (detach first)
8. Subnets
9. Route Tables
10. VPC
11. Security Groups
12. S3 Bucket (empty it first)

### Verify Cleanup

```bash
# Check for remaining resources
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*terraform*"
aws elbv2 describe-load-balancers
aws s3 ls | grep terraform
```

### Cleanup Backend Resources (Optional)

**⚠️ Warning:** Only do this if you're completely done with the demo!

```bash
# 1. Delete state files from S3
aws s3 rm s3://techtutorialswithpiyush-terraform-state/dev/terraform.tfstate
aws s3 rm s3://techtutorialswithpiyush-terraform-state/prod/terraform.tfstate

# 2. Delete lock files (if any remain)
aws s3 rm s3://techtutorialswithpiyush-terraform-state/dev/terraform.tfstate.tflock
aws s3 rm s3://techtutorialswithpiyush-terraform-state/prod/terraform.tfstate.tflock

# 3. List remaining files
aws s3 ls s3://techtutorialswithpiyush-terraform-state/ --recursive

# 4. Only if empty and you own the bucket:
aws s3 rb s3://techtutorialswithpiyush-terraform-state --force
```

---

## Troubleshooting

### Issue: Workflow Fails with "403 Forbidden"

**Cause:** Missing GitHub permissions

**Solution:**

- Check workflow has `permissions:` block
- Verify `issues: write` permission exists
- Check GitHub Actions are enabled in repo settings

### Issue: Concurrent Terraform Runs

**S3 Native Locking (Terraform 1.10.0+):**

- Creates `.tflock` files in S3 during operations
- Prevents concurrent modifications automatically
- If locked, you'll see: "Error acquiring the state lock"

**How it works:**

```
terraform apply starts → Creates dev/terraform.tfstate.tflock
Another apply tries    → Sees lock file → Waits or fails
First apply completes  → Deletes .tflock file
```

**If lock gets stuck:**

```bash
# List lock files
aws s3 ls s3://techtutorialswithpiyush-terraform-state/ --recursive | grep tflock

# Manually remove stuck lock (only if you're sure no operation is running)
aws s3 rm s3://techtutorialswithpiyush-terraform-state/prod/terraform.tfstate.tflock
# Or for dev:
aws s3 rm s3://techtutorialswithpiyush-terraform-state/dev/terraform.tfstate.tflock
```

**State corruption recovery:**

```bash
# Restore from S3 version history
aws s3api list-object-versions \
  --bucket YOUR-BUCKET-NAME \
  --prefix prod/terraform.tfstate

# Download previous version
aws s3api get-object \
  --bucket YOUR-BUCKET-NAME \
  --key prod/terraform.tfstate \
  --version-id VERSION-ID \
  terraform.tfstate
```

### Issue: "Backend Configuration Changed"

**Cause:** Backend configuration was modified or state was moved

**Solution:**

```bash
# Reconfigure backend
terraform init -reconfigure -backend-config="backend-prod.hcl" \
  -backend-config="bucket=$TERRAFORM_STATE_BUCKET"

# Or migrate state
terraform init -migrate-state
```

### Issue: "Failed to Load State"

**Cause:** S3 bucket doesn't exist or wrong bucket name

**Check:**

```bash
# Verify bucket exists and you have access
aws s3 ls s3://techtutorialswithpiyush-terraform-state/

# Verify GitHub secret is set correctly
# Settings → Secrets → TERRAFORM_STATE_BUCKET
# Value should be: techtutorialswithpiyush-terraform-state
```

### Issue: Drift Detection Not Running

**Possible causes:**

1. Not on main branch (it only runs on prod)
2. GitHub Actions disabled
3. Schedule not reached yet

**Check:**

```bash
git branch  # Verify you're on main
```

### Issue: Auto-Apply Fails

**Common causes:**

- IAM permission insufficient
- Resource dependencies (e.g., can't delete VPC with resources)
- Rate limiting

**Solution:**

- Check workflow logs for specific error
- Verify AWS credentials have full permissions
- May need manual intervention

### Issue: S3 Bucket Not Deleting

**Cause:** Bucket not empty

**Solution:**

```bash
# Empty the bucket first
aws s3 rm s3://YOUR-BUCKET-NAME --recursive
# Then destroy
terraform destroy
```

### Issue: NAT Gateway Delete Timeout

**Cause:** NAT Gateway takes 3-5 minutes to delete

**Solution:**

- Be patient, this is normal
- Don't interrupt the destroy process
- If timeout occurs, run destroy again

### Issue: Slack Notifications Not Working

**Check:**

1. Webhook URL is correct and active
2. Secret name is exactly `SLACK_WEBHOOK_URL`
3. Webhook has permission to post to channel

---

## Cost Considerations

### Estimated Costs (us-east-1)

| Resource | Approximate Cost |
|----------|------------------|
| NAT Gateway | ~$0.045/hour (~$32/month) |
| ALB | ~$0.025/hour (~$18/month) |
| EC2 t2.micro (1-3) | ~$0.0116/hour each (~$8.5/month each) |
| Data Transfer | Varies |
| S3 | Minimal (< $1/month) |

**Total: ~$50-70/month if left running**

**Cost Saving Tips:**

- ✅ Destroy dev when not in use
- ✅ Use scheduled shutdown for dev instances
- ✅ Consider using AWS free tier (if eligible)
- ✅ Monitor with AWS Cost Explorer

---

## Demo Script

### Quick 10-Minute Demo

**Preparation (5 min):**

1. Deploy prod environment (let it run)
2. Open GitHub Actions, AWS Console, Slack

**Demo Flow (10 min):**

**Minute 1-2: Overview**

- "This is automated drift detection with auto-remediation"
- Show architecture diagram
- Explain dev/prod split

**Minute 3-4: Show Deployed Infrastructure**

- AWS Console → Show VPC, ALB, ASG
- Show healthy instances
- Copy ALB DNS, show in browser (if app deployed)

**Minute 5-6: Introduce Drift**

- AWS Console → EC2 → Security Groups
- Find ALB security group (e.g., `dev-alb-sg`)
- Add dangerous inbound rule: Port 22, Source 0.0.0.0/0
- "This simulates a critical security violation allowing SSH from anywhere"

**Minute 7-8: Watch Automatic Detection**

- Wait ~1 minute (drift detection runs every 1 minute)
- GitHub Actions → Drift detection workflow triggers automatically
- Watch it detect the unauthorized security group rule change
- Show GitHub issue being created with drift details and security alert

**Minute 9: Auto-Remediation**

- Watch terraform apply run automatically
- Show Slack notification with drift remediation alert
- Refresh AWS Console → Unauthorized SSH rule is removed

**Minute 10: Wrap Up**

- Show GitHub issue closed automatically
- Explain 1-minute automated drift detection schedule
- Show destroy workflow for safe cleanup

---

## Detailed Workflow Architecture & Internals

This section provides an in-depth technical breakdown of how each workflow operates, what happens behind the scenes, and how all the components work together.

---

### System Architecture Overview

```
GitHub Repository (Code)
         ↓
    GitHub Actions (CI/CD)
         ↓
    ┌────────────────────────────────────┐
    │                                    │
    ↓                                    ↓
AWS Resources                   S3 State Backend
(VPC, ALB, EC2, etc.)           (Source of Truth)
    ↑                                    │
    └────────────────────────────────────┘
         State Sync & Locking
```

**Key Components:**

1. **GitHub Repository:** Source code and Terraform configurations
2. **GitHub Actions:** Automation engine running workflows
3. **S3 Backend:** Centralized state storage with locking
4. **AWS Resources:** Actual infrastructure being managed
5. **GitHub Issues:** Drift tracking and audit trail
6. **Slack (optional):** Real-time notifications

---

### Workflow 1: CI/CD Pipeline - Deep Dive

**File:** `.github/workflows/terraform.yml`

#### Architecture: Two-Job Sequential Workflow

```
terraform-plan (Job 1)
    │
    ├─ Runs on: ubuntu-latest
    ├─ Duration: ~2-3 minutes
    ├─ Output: tfplan artifact
    └─ Always runs
         │
         ↓
terraform-apply (Job 2)
    │
    ├─ Runs on: ubuntu-latest  (new VM)
    ├─ Duration: ~5-10 minutes
    ├─ Input: tfplan artifact
    └─ Only on push events
```

---

#### Job 1: Plan - Step-by-Step Technical Breakdown

**Step 1: Checkout Repository**

```yaml
- name: Checkout
  uses: actions/checkout@v4
```

**Technical details:**

- Uses GitHub's checkout action (v4)
- Clones entire repository to `/home/runner/work/terraform-drift-detection/`
- Fetches full git history (useful for drift tracking)
- Sets up git credentials for potential future commits

**Step 2: Determine Environment**

```yaml
if [[ "${{ github.ref_name }}" == "main" ]]; then
  echo "ENVIRONMENT=prod" >> $GITHUB_ENV
else
  echo "ENVIRONMENT=dev" >> $GITHUB_ENV
fi
```

**What happens:**

- `github.ref_name` contains the branch name
- Sets `ENVIRONMENT` environment variable for all subsequent steps
- Drives backend config selection and resource naming
- Available to all steps as `${{ env.ENVIRONMENT }}`

**Step 3: Configure AWS Credentials**

```yaml
- uses: aws-actions/configure-aws-credentials@v2
```

**Behind the scenes:**

- Reads secrets from GitHub's encrypted secrets store
- Sets environment variables:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION`
- Creates AWS credential file at `~/.aws/credentials`
- Validates credentials with STS GetCallerIdentity API call
- If validation fails, workflow terminates immediately

**Step 4: Setup Terraform**

```yaml
- uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.10.3
    terraform_wrapper: false
```

**What it installs:**

- Downloads Terraform 1.10.3 binary from releases.hashicorp.com
- Extracts to `/usr/local/bin/terraform`
- Verifies checksum for security
- `terraform_wrapper: false` prevents wrapper script (cleaner output)
- Adds terraform to PATH

**Step 5: Terraform Init**

```yaml
terraform init -backend-config="backend-${{ env.ENVIRONMENT }}.hcl"
```

**Detailed initialization process:**

1. **Read backend configuration:**

   ```hcl
   # backend-dev.hcl
   bucket       = "techtutorialswithpiyush-terraform-state"
   key          = "dev/terraform.tfstate"
   region       = "us-east-1"
   use_lockfile = true
   encrypt      = true
   ```

2. **Connect to S3:**
   - Validates bucket exists and is accessible
   - Checks IAM permissions (s3:GetObject, s3:PutObject)
   - Enables server-side encryption (AES-256)

3. **Download state file:**
   - Fetches `dev/terraform.tfstate` from S3
   - Loads into memory as current state
   - If doesn't exist, initializes empty state

4. **Download providers:**
   - Reads `required_providers` from terraform block
   - Downloads AWS provider (~400MB) to `.terraform/providers/`
   - Downloads Random provider (~10MB)
   - Caches providers for future runs

5. **Create lock file:**
   - Generates `.terraform.lock.hcl` with provider versions
   - Ensures consistent provider versions across runs

**Step 6-7: Format Check & Validate**

```yaml
terraform fmt -check
terraform validate
```

**Format check:**

- Scans all `*.tf` files
- Compares against canonical formatting rules
- Reports files needing formatting
- `continue-on-error: true` allows workflow to continue

**Validate:**

- Parses all Terraform configuration
- Checks syntax errors
- Validates resource references
- Ensures required variables defined
- Does NOT check provider credentials

**Step 8: Terraform Plan**

```yaml
terraform plan -no-color -out=tfplan | tee plan_output.txt
```

**Plan generation process:**

1. **Load current state:**
   - Reads state file from memory (downloaded during init)
   - Contains IDs of all managed resources

2. **Refresh (implicit):**
   - Queries AWS APIs for current resource attributes
   - Updates state with latest values
   - Detects manual changes made outside Terraform

3. **Read configuration:**
   - Parses all `.tf` files in current directory
   - Builds dependency graph
   - Resolves variable values

4. **Calculate diff:**
   - Compares desired state (config) vs current state (S3/AWS)
   - Generates list of operations needed

5. **Create execution plan:**
   - Determines order of operations (respects dependencies)
   - Saves to binary file: `tfplan`
   - Generates human-readable output

**Example plan output:**

```terraform
Terraform will perform the following actions:

  # aws_instance.web[0] will be created
  + resource "aws_instance" "web" {
      + ami           = "ami-12345678"
      + instance_type = "t2.micro"
      + tags          = {
          + "Environment" = "dev"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Step 9: Comment on PR** (PRs only)

```yaml
uses: actions/github-script@v6
```

**What happens:**

- Reads `plan_output.txt`
- Truncates if > 65,000 characters (GitHub limit)
- Formats as markdown code block
- Posts as PR comment via GitHub API
- Updates existing comment if already posted
- Allows reviewers to see infrastructure changes before merge

**Step 10: Upload Plan Artifact**

```yaml
uses: actions/upload-artifact@v4
if: steps.plan.outcome == 'success'
with:
  name: tfplan-${{ env.ENVIRONMENT }}
  path: tfplan
  retention-days: 5
  if-no-files-found: warn
```

**Artifact upload process:**

- **Compression:** gzip the `tfplan` file (~100KB → ~10KB)
- **Upload:** POST to GitHub's artifact storage API
- **Storage:** GitHub stores in Azure Blob Storage
- **Naming:** `tfplan-dev` or `tfplan-prod`
- **Expiration:** Auto-deleted after 5 days
- **Conditional:** Only if plan succeeded and file exists

---

#### Job 2: Apply - Step-by-Step Technical Breakdown

**Dependency & Condition:**

```yaml
needs: terraform-plan
if: github.event_name == 'push' && needs.terraform-plan.result == 'success'
```

- Waits for Plan job to complete
- Only runs on direct pushes (not PRs)
- Skips if Plan failed
- Runs on fresh VM (no filesystem sharing with Job 1)

**Steps 1-5: Setup** (Same as Plan job)

- Fresh checkout of code
- Environment determination
- AWS authentication
- Terraform installation
- Backend initialization & state download

**Step 6: Download Plan Artifact**

```yaml
uses: actions/download-artifact@v4
continue-on-error: true
id: download
with:
  name: tfplan-${{ env.ENVIRONMENT }}
```

**Download process:**

- **API call:** GET from GitHub artifact storage
- **Decompress:** Unzip the artifact
- **Save:** Places `tfplan` in current directory
- **Graceful failure:** If artifact doesn't exist (no changes), continues
- **Why might not exist?** Second push with identical code

**Step 7: Check if Plan Exists**

```yaml
if [ -f "tfplan" ]; then
  echo "plan_exists=true" >> $GITHUB_OUTPUT
else
  echo "plan_exists=false" >> $GITHUB_OUTPUT
fi
```

**File system check:**

- Tests if `tfplan` file exists in working directory
- Sets output variable for conditional execution
- Prevents "file not found" errors in apply step

**Step 8: Terraform Apply** (conditional)

```yaml
if: steps.check-plan.outputs.plan_exists == 'true'
terraform apply -auto-approve tfplan
```

**Apply execution process:**

1. **Read plan file:**
   - Loads binary `tfplan`
   - Contains exact operations to perform
   - Includes all resolved values

2. **Acquire state lock:**
   - Creates `dev/terraform.tfstate.tflock` in S3
   - Lock contains:

     ```json
     {
       "ID": "a1b2c3d4-...",
       "Operation": "OperationTypeApply",
       "Info": "github-actions",
       "Who": "github-runner@ubuntu",
       "Created": "2025-12-24T10:30:00Z",
       "Path": "dev/terraform.tfstate"
     }
     ```

   - Prevents concurrent modifications

3. **Execute operations:**
   - Creates resources in dependency order
   - Makes AWS API calls for each resource
   - Examples:
     - `ec2:RunInstances` for EC2
     - `elasticloadbalancing:CreateLoadBalancer` for ALB
     - `ec2:CreateVpc` for VPC

4. **Update state file:**
   - After each resource creation, updates state
   - Records resource IDs, ARNs, attributes
   - Example state entry:

     ```json
     {
       "mode": "managed",
       "type": "aws_instance",
       "name": "web",
       "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
       "instances": [{
         "attributes": {
           "id": "i-0123456789abcdef",
           "ami": "ami-12345678",
           "instance_type": "t2.micro",
           "public_ip": "54.123.45.67"
         }
       }]
     }
     ```

5. **Upload state to S3:**
   - Backs up current state: `terraform.tfstate` → `terraform.tfstate.backup`
   - Uploads new state to `terraform.tfstate`
   - Uses S3's PutObject with server-side encryption

6. **Release lock:**
   - Deletes `.tflock` file from S3
   - Allows other operations to proceed

**Step 9: Output Infrastructure Info**

```yaml
terraform output >> $GITHUB_STEP_SUMMARY
```

- Reads outputs defined in `outputs.tf`
- Formats as GitHub Actions summary
- Visible in workflow run UI
- Examples: ALB DNS, VPC ID, subnet IDs

---

### Workflow 2: Drift Detection - Deep Dive

**File:** `.github/workflows/drift_detection.yml`

#### Single-Job Architecture with Conditional Logic

```
drift-detection (Single Job)
    │
    ├─ Trigger: Schedule (every 1 minute)
    ├─ Trigger: Manual
    ├─ Trigger: Push to main/dev
    │
    ├─ terraform plan -detailed-exitcode
    │   └─ Captures exit code (0, 1, or 2)
    │
    ├─ If exit code 2 (drift):
    │   ├─ Create/update GitHub issue
    │   ├─ terraform apply -auto-approve
    │   ├─ Send Slack notification
    │   └─ Close issue on success
    │
    └─ If exit code 0 (no drift):
        └─ Close any open drift issues
```

---

#### Detailed Step Analysis

**Step 1-5: Standard Setup**

- Checkout, environment detection, AWS config, Terraform setup, init
- Same as CI/CD workflow

**Step 6: Drift Detection Plan**

```yaml
set +e
terraform plan -detailed-exitcode -no-color > plan_output.txt 2>&1
EXIT_CODE=$?
echo "exitcode=$EXIT_CODE" >> $GITHUB_OUTPUT
cat plan_output.txt
exit 0
```

**Understanding Exit Codes:**

- **Exit Code 0:** ✅ No drift - infrastructure perfectly matches code
- **Exit Code 1:** ❌ Error - syntax error, API failure, etc.
- **Exit Code 2:** ⚠️ Drift detected - infrastructure differs from code

**Why `set +e`?**

- Bash normally exits on non-zero return codes
- Exit code 2 isn't an error in our context
- `set +e` disables immediate exit
- Allows capturing exit code in `$?`

**Why `exit 0`?**

- Ensures step always succeeds
- Workflow continues to remediation logic
- Without this, GitHub Actions would mark step as failed

**What drift detection catches:**

- Manual AWS Console changes
- CLI/SDK modifications
- Changes by other automation
- Accidental deletions
- Configuration drift over time

**Example drift scenarios:**

1. **Tag modification:**

   ```
   # Plan shows
   ~ resource "aws_instance" "web" {
       ~ tags = {
           ~ "Environment" = "dev" -> "development"  # Changed manually
         }
     }
   ```

2. **Security group rule added:**

   ```
   ~ resource "aws_security_group" "alb" {
       ~ ingress {
           + cidr_blocks = ["0.0.0.0/0"]  # Unauthorized SSH access
           + from_port   = 22
           + to_port     = 22
         }
     }
   ```

**Step 7: Analyze Drift** (if exitcode == 2)

```yaml
uses: actions/github-script@v6
```

**Issue creation/update logic:**

```javascript
// Search for existing drift issues
const issues = await github.rest.issues.listForRepo({
  state: 'open',
  labels: 'drift-detection'
});

// Find environment-specific issue
const existingIssue = issues.data.find(issue => 
  issue.title.includes(`[${env}]`)
);

if (existingIssue) {
  // Update existing issue with new drift info
  await github.rest.issues.createComment({
    issue_number: existingIssue.number,
    body: `## New Drift Detected\n\n${planOutput}`
  });
} else {
  // Create new issue
  await github.rest.issues.create({
    title: `🚨 Terraform Drift Detected [${env}]`,
    body: driftDetails,
    labels: ['drift-detection', 'auto-fix', env]
  });
}
```

**Issue content includes:**

- Timestamp of detection
- Environment (dev/prod)
- Full terraform plan showing changes
- Link to workflow run
- Auto-fix status

**Step 8: Auto-Fix Drift** (if exitcode == 2)

```yaml
terraform apply -auto-approve -no-color > apply_output.txt 2>&1
continue-on-error: true
```

**Auto-remediation process:**

1. Reads current drift plan
2. Acquires state lock
3. Applies changes to restore desired state
4. Examples:
   - Removes unauthorized tags
   - Reverts security group changes
   - Restores original configurations
   - Recreates deleted resources
5. Updates state file
6. Releases lock

**Safety considerations:**

- Only fixes detected drift
- Doesn't create new resources (unless previously deleted)
- Maintains exact configuration from code
- All changes logged in workflow output

**Step 9-10: Slack Notifications**

**Success notification:**

```json
{
  "text": "✅ Terraform Drift Auto-Fixed",
  "blocks": [{
    "type": "header",
    "text": "✅ Drift Detected & Automatically Fixed"
  }, {
    "type": "section",
    "text": "*Repository:* terraform-drift-detection\n*Environment:* dev\n*Link:* <workflow-url>"
  }]
}
```

**Failure notification:**

```json
{
  "text": "❌ Terraform Drift Auto-Fix Failed",
  "blocks": [{
    "type": "header",
    "text": "❌ Manual Intervention Required"
  }]
}
```

**Step 11: Update/Close Issues**

**On successful fix:**

- Posts comment: "✅ Drift remediated"
- Closes issue
- Updates labels

**On no drift (exitcode == 0):**

- Finds all open drift issues for environment
- Posts: "✅ No drift detected. Infrastructure in sync"
- Closes all related issues
- Keeps issue board clean

---

### Workflow 3: Destroy - Deep Dive

**File:** `.github/workflows/destroy.yml`

#### Safety-First Architecture

```
destroy-infrastructure (Single Job)
    │
    ├─ Manual trigger only
    ├─ Requires:
    │   ├─ Environment selection (dev/prod)
    │   └─ Confirmation: "DESTROY"
    │
    ├─ terraform plan -destroy
    │   └─ Shows what will be destroyed
    │
    ├─ Create tracking issue
    │
    ├─ terraform destroy -auto-approve
    │   └─ Destroys all resources
    │
    └─ Update issue with results
```

---

#### Safety Mechanisms in Detail

**1. Manual Trigger Only**

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, prod]
      confirmation:
        type: string
        required: true
```

- No automatic triggers
- Must navigate to Actions tab
- Click "Run workflow"
- Fill in required inputs
- Deliberate multi-step process

**2. Confirmation String Validation**

```yaml
if: inputs.confirmation == 'DESTROY'
```

- Case-sensitive match
- Must type exactly "DESTROY"
- Typos prevent execution
- Similar to AWS Console deletions

**3. Environment Approval Gates** (if configured)

```yaml
environment: ${{ inputs.environment }}
```

- Can require manual approval for prod
- Designated reviewers notified
- Optional wait timer
- Approval history tracked

**4. Tracking Issue**

```yaml
await github.rest.issues.create({
  title: '🗑️ Infrastructure Destruction - ${env}',
  body: `Initiated by: @${context.actor}\nTimestamp: ${timestamp}\nEnvironment: ${env}`,
  labels: ['infrastructure', 'destruction', env]
});
```

- Creates audit trail
- Records who initiated
- Documents what was destroyed
- Permanent record

---

#### Destruction Process

**Step 6: Destroy Plan**

```yaml
terraform plan -destroy -no-color
```

- Shows all resources to be destroyed
- Final opportunity to review
- No actual destruction yet
- Output includes:
  - List of all resources
  - Dependencies
  - Destruction order

**Step 7: Execute Destroy**

```yaml
terraform destroy -auto-approve -no-color
```

**Destruction sequence (managed by Terraform):**

1. **EC2 Instances:**
   - Terminates all instances in ASG
   - Waits for termination (~30 seconds)

2. **Auto Scaling Group:**
   - Sets desired capacity to 0
   - Deletes ASG configuration

3. **Load Balancer:**
   - Deregisters targets
   - Deletes listeners
   - Deletes ALB (~2 minutes)

4. **Target Groups:**
   - Removes target registrations
   - Deletes target groups

5. **NAT Gateway:**
   - Deletes NAT Gateway
   - **Takes 3-5 minutes** (AWS limitation)
   - Releases Elastic IP

6. **Internet Gateway:**
   - Detaches from VPC
   - Deletes IGW

7. **Subnets:**
   - Ensures no dependencies
   - Deletes public/private subnets

8. **Route Tables:**
   - Removes routes
   - Disassociates from subnets
   - Deletes route tables

9. **VPC:**
   - Final dependency check
   - Deletes VPC

10. **Security Groups:**
    - Removes ingress/egress rules
    - Deletes security groups

11. **S3 Buckets** (if managed):
    - Must be empty first
    - Deletes bucket

**State file updates:**

- Each deleted resource removed from state
- State file still exists in S3 (for audit)
- Can be used to recreate infrastructure

**Step 8: Update Tracking Issue**

```yaml
await github.rest.issues.createComment({
  body: '✅ Infrastructure successfully destroyed'
});
await github.rest.issues.update({
  state: 'closed'
});
```

---

### Key Concepts: State Management Deep Dive

#### S3 Backend Architecture

```
S3 Bucket: techtutorialswithpiyush-terraform-state
│
├── dev/
│   ├── terraform.tfstate          # Current state (JSON)
│   ├── terraform.tfstate.backup   # Previous version
│   └── terraform.tfstate.tflock   # Lock file (temporary)
│
└── prod/
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── terraform.tfstate.tflock
```

#### State File Contents (Example)

```json
{
  "version": 4,
  "terraform_version": "1.10.3",
  "serial": 42,
  "lineage": "a1b2c3d4-e5f6-...",
  "outputs": {
    "alb_dns_name": {
      "value": "dev-alb-1234567890.us-east-1.elb.amazonaws.com"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [{
        "schema_version": 1,
        "attributes": {
          "id": "vpc-0123456789abcdef",
          "cidr_block": "10.0.0.0/16",
          "enable_dns_hostnames": true,
          "tags": {
            "Name": "dev-vpc",
            "Environment": "dev"
          }
        }
      }]
    }
  ]
}
```

#### State Locking Flow

```
Workflow A: terraform apply
│
├─ Step 1: Check for lock file
│   └─ s3://bucket/dev/terraform.tfstate.tflock exists?
│       ├─ YES → Fail with "State locked" error
│       └─ NO → Continue
│
├─ Step 2: Create lock file
│   └─ PUT s3://bucket/dev/terraform.tfstate.tflock
│       Content: { "ID": "abc123", "Who": "github-actions", ... }
│
├─ Step 3: Perform operations
│   ├─ Modify infrastructure
│   └─ Update state file
│
└─ Step 4: Release lock
    └─ DELETE s3://bucket/dev/terraform.tfstate.tflock
```

**Concurrent workflow handling:**

```
Time: 10:00:00 - Workflow A starts
Time: 10:00:01 - Workflow A acquires lock
Time: 10:00:15 - Workflow B starts
Time: 10:00:16 - Workflow B tries to acquire lock
Time: 10:00:16 - Workflow B fails: "State is locked by Workflow A"
Time: 10:05:30 - Workflow A completes, releases lock
Time: 10:05:31 - Workflow B can now be re-run successfully
```

---

### Troubleshooting Guide

#### Common Issues & Solutions

**1. "Artifact not found"**

```
Error: Unable to download artifact(s): Artifact not found for name: tfplan-dev
```

**Cause:** Infrastructure unchanged, no plan artifact created  
**Solution:** Workflow now handles gracefully, shows "No changes to apply"  
**State file:** Always accessible in S3, unaffected by artifact issues

**2. "State is locked"**

```
Error: Error acquiring the state lock
Lock Info:
  ID:        a1b2c3d4-e5f6-...
  Operation: OperationTypeApply
  Who:       github-actions@ubuntu
```

**Cause:** Another workflow or local run in progress  
**Solution:**

- Wait for other operation to complete
- Check running workflows in Actions tab
- Emergency unlock (only if certain):

  ```bash
  aws s3 rm s3://techtutorialswithpiyush-terraform-state/dev/terraform.tfstate.tflock
  ```

**3. "Exit code 2" marked as failure**

```
Error: Process completed with exit code 2.
```

**Cause:** Exit code 2 = drift detected (not an error!)  
**Solution:** Workflow now captures exit code properly with `set +e` and `exit 0`

**4. "Backend configuration changed"**

```
Error: Backend configuration changed
```

**Cause:** S3 bucket name or key changed  
**Solution:**

```bash
terraform init -reconfigure -backend-config="backend-dev.hcl"
```

---

### Monitoring & Observability

#### GitHub Actions Interface

**Workflow Run Page:**

- Real-time log streaming
- Step-by-step execution status
- Timing information per step
- Artifact download links
- Re-run capabilities

**Annotations:**

- Error messages highlighted
- Warning indicators
- Line numbers for failures

**Summary Page:**

- Infrastructure outputs
- Deployment status
- Links to created issues
- Environment information

#### GitHub Issues

**Drift Detection Issues:**

- Created automatically on drift
- Tagged with environment label
- Contains full plan output
- Updated with remediation status
- Closed automatically when fixed

**Destruction Tracking:**

- Created on destroy workflow trigger
- Records initiator and timestamp
- Documents destroyed resources
- Permanent audit trail

#### Slack Integration

**Message Format:**

```
✅ Terraform Drift Auto-Fixed
━━━━━━━━━━━━━━━━━━━━━━━━
Repository: terraform-drift-detection
Branch: main
Environment: prod
Workflow: <clickable link>
━━━━━━━━━━━━━━━━━━━━━━━━
Terraform automatically applied changes to remediate infrastructure drift.
```

#### S3 State Versioning

**View all versions:**

```bash
aws s3api list-object-versions \
  --bucket techtutorialswithpiyush-terraform-state \
  --prefix dev/terraform.tfstate
```

**Output:**

```json
{
  "Versions": [
    {
      "Key": "dev/terraform.tfstate",
      "VersionId": "abc123...",
      "LastModified": "2025-12-24T10:30:00Z",
      "Size": 45678
    },
    {
      "Key": "dev/terraform.tfstate",
      "VersionId": "def456...",
      "LastModified": "2025-12-24T09:00:00Z",
      "Size": 44123
    }
  ]
}
```

**Rollback to previous version:**

```bash
aws s3api get-object \
  --bucket techtutorialswithpiyush-terraform-state \
  --key dev/terraform.tfstate \
  --version-id def456... \
  terraform.tfstate.backup
```

---

### Security Considerations

#### Secrets Management

- **Storage:** GitHub encrypts secrets at rest
- **Access:** Only available to workflows, never logged
- **Rotation:** Update in Settings → Secrets without code changes
- **Scope:** Repository-level (could be organization-level)

#### IAM Permissions Required

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ],
    "Resource": "*"
  }]
}
```

#### State File Security

- **Encryption:** AES-256 server-side encryption
- **Access:** IAM-controlled, audit with CloudTrail
- **Versioning:** Enabled for rollback and audit
- **Locking:** Prevents corruption from concurrent access

---

## Advanced Topics

### Remote State Management

**Separate State Files:**

- Dev: `s3://techtutorialswithpiyush-terraform-state/dev/terraform.tfstate`
- Prod: `s3://techtutorialswithpiyush-terraform-state/prod/terraform.tfstate`

**S3 Native State Locking (Terraform 1.10.0+):**

- ✅ Uses S3 conditional writes for locking
- ✅ Creates `.tflock` files during operations
- ✅ Prevents concurrent modifications automatically
- ✅ No DynamoDB needed - simpler and cheaper
- ✅ Lock files: `dev/terraform.tfstate.tflock` and `prod/terraform.tfstate.tflock`

**How it works:**

1. `terraform apply` starts → Creates lock file in S3
2. Concurrent `terraform apply` → Detects lock file → Fails/waits
3. First operation completes → Deletes lock file

**State Versioning:**

- S3 versioning enabled automatically
- Can rollback to previous state if needed

```bash
# List state versions
aws s3api list-object-versions \
  --bucket techtutorialswithpiyush-terraform-state \
  --prefix prod/terraform.tfstate

# Restore previous version
aws s3api get-object \
  --bucket techtutorialswithpiyush-terraform-state \
  --key prod/terraform.tfstate \
  --version-id VERSION-ID \
  terraform.tfstate.backup
```

### Migrate Existing State to Remote Backend

If you have local state files:

```bash
# 1. Add backend configuration to your code
# (already done in backend.tf)

# 2. Initialize with migration
terraform init -migrate-state \
  -backend-config="backend-prod.hcl" \
  -backend-config="bucket=$TERRAFORM_STATE_BUCKET"

# 3. Confirm migration when prompted
```

### Multi-Region Deployment

Modify `variables.tf`:

```hcl
variable "aws_region" {
  default = "us-west-2"  # Change region
}
```

### Using OIDC Instead of Access Keys

For better security, use OIDC for GitHub Actions:

```yaml
# In workflow file
permissions:
  id-token: write
  contents: read

- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole
    aws-region: us-east-1
```

### State Backend Configuration (Already Implemented!)

The project now uses S3 backend:

```hcl
# backend.tf
terraform {
  backend "s3" {
    # Config provided at init time via backend-*.hcl files
  }
}
```

**Benefits:**

- ✅ Separate state files for dev/prod
- ✅ S3 native state locking (no DynamoDB)
- ✅ Versioning for state history
- ✅ Encryption at rest
- ✅ Simplified setup - only S3 needed
- ✅ Automatic lock management

### Disable Auto-Fix (Detection Only)

In `drift_detection.yml`, remove or comment out:

```yaml
- name: Auto-Fix Drift
  # Comment out this entire step
```

---

## Best Practices

### For Production Use

1. **✅ Use Remote State Backend**
   - S3 + DynamoDB for locking
   - Enable versioning and encryption

2. **✅ Implement Proper IAM**
   - Use IAM roles, not access keys
   - OIDC for GitHub Actions
   - Least privilege principle

3. **✅ Add Plan Review**
   - Require approval for prod applies
   - Manual review before auto-fix

4. **✅ Sensitive Data**
   - Sanitize plan outputs
   - Don't log secrets
   - Use AWS Secrets Manager

5. **✅ Monitoring**
   - CloudWatch for AWS resources
   - GitHub Action notifications
   - Log aggregation

6. **✅ Testing**
   - Test in dev first
   - Validate plans before apply
   - Regular disaster recovery drills

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

## Support

**Issues?**

- Check [Troubleshooting](#troubleshooting) section
- Review workflow logs in GitHub Actions
- Check AWS CloudTrail for API errors
- Open issue in this repository

---

## License

MIT License - Feel free to use and modify for your demos!

---

**Happy Drifting! 🚀**
