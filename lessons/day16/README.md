# Day 16: AWS IAM User Management with Terraform

## Overview
This demo demonstrates how to manage AWS IAM users, groups, and group memberships using Terraform and a CSV file as the data source. It's an AWS equivalent of Azure AD user management.

## What Gets Created

- **26 IAM Users** with console access
- **3 IAM Groups** (Education, Managers, Engineers)
- **Group Memberships** based on user attributes
- **User Tags** with metadata (DisplayName, Department, JobTitle)

## Prerequisites

1. **AWS CLI** configured with credentials
2. **Terraform** v1.0 or later
3. **AWS Permissions**: IAM user creation and management permissions
4. **S3 Bucket** for Terraform state (see setup below)

## Quick Start

### 1. Create S3 Backend Bucket

```powershell
aws s3 mb s3://my-terraform-state-bucket-piyushsachdeva --region us-east-1
aws s3api put-bucket-versioning --bucket my-terraform-state-bucket-piyushsachdeva --versioning-configuration Status=Enabled
```

### 2. Initialize Terraform

```powershell
terraform init
```

### 3. Review Changes

```powershell
terraform plan
```

### 4. Apply Configuration

```powershell
terraform apply -auto-approve
```

### 5. Verify in AWS Console

Go to [IAM Console](https://console.aws.amazon.com/iam/) and check:
- **Users** section - 26 users created
- **User groups** section - 3 groups with members

## File Structure

```
day16/
├── backend.tf          # S3 backend configuration
├── provider.tf         # AWS provider setup
├── versions.tf         # Terraform and provider versions
├── main.tf            # User creation and CSV parsing
├── groups.tf          # Group and membership management
├── users.csv          # User data source
├── DEMO_GUIDE.md      # Comprehensive demo walkthrough
└── README.md          # This file
```

## How It Works

### Step 1: Read CSV File

The `main.tf` file reads the `users.csv` file:

```terraform
locals {
  users = csvdecode(file("users.csv"))
}
```

### Step 2: Create IAM Users

Users are created with a username format: `{first_initial}{lastname}` (e.g., `mscott`):

```terraform
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  
  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  path = "/users/"
  
  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department"  = each.value.department
    "JobTitle"    = each.value.job_title
  }
}
```

### Step 3: Enable Console Access

Login profiles are created for console access with password reset required:

```terraform
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users
  
  user                    = each.value.name
  password_reset_required = true
}
```

### Step 4: Create Groups and Memberships

Groups are created and users are dynamically assigned based on their department:

```terraform
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

resource "aws_iam_group_membership" "education_members" {
  name  = "education-group-membership"
  group = aws_iam_group.education.name
  
  users = [
    for user in aws_iam_user.users : user.name 
    if user.tags.Department == "Education"
  ]
}
```

## Outputs

After applying, you can view the outputs:

```powershell
# View AWS Account ID
terraform output account_id

# View all user names
terraform output user_names

# View password information (sensitive)
terraform output user_passwords
```

## User List

The following users are created from `users.csv`:

| Username | Full Name | Department | Job Title |
|----------|-----------|------------|-----------|
| mscott | Michael Scott | Education | Regional Manager |
| dschrute | Dwight Schrute | Sales | Assistant to the Regional Manager |
| jhalpert | Jim Halpert | Sales | Sales Representative |
| pbeesly | Pam Beesly | Reception | Receptionist |
| rhoward | Ryan Howard | Temps | Temp |
| ... and 21 more users |

## Groups and Memberships

### Education Group
- Michael Scott (mscott)

### Managers Group
Users with "Manager" or "CEO" in their job title:
- Michael Scott (mscott)
- Robert California (rcalifornia)
- Darryl Philbin (dphilbin)
- David Wallace (dwallace)
- Jo Bennett (jbennett)

### Engineers Group
- Currently empty (no users with "Engineering" department in CSV)

## Customization

### Add More Users

Edit `users.csv` and add new rows:

```csv
first_name,last_name,department,job_title
Jane,Doe,Engineering,Software Engineer
```

Then run:

```powershell
terraform apply
```

### Add IAM Policies to Groups

Add to `groups.tf`:

```terraform
resource "aws_iam_group_policy_attachment" "education_readonly" {
  group      = aws_iam_group.education.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

### Change Username Format

Modify the `name` attribute in `main.tf`:

```terraform
# Current: {first_initial}{lastname} (e.g., mscott)
name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")

# Alternative: {firstname}.{lastname} (e.g., michael.scott)
name = lower("${each.value.first_name}.${each.value.last_name}")
```

## Password Management

AWS doesn't return auto-generated passwords without PGP encryption. To set passwords:

### Option 1: AWS Console
1. Go to IAM Console
2. Select a user
3. Click "Security credentials"
4. Click "Enable console access" or "Manage console access"
5. Set a password

### Option 2: AWS CLI

```powershell
aws iam create-login-profile --user-name mscott --password "TempPassword123!" --password-reset-required
```

## Cleanup

To remove all created resources:

```powershell
terraform destroy
```

**Warning:** This will delete all users, groups, and memberships.

## Troubleshooting

### Error: Backend Access Denied

Check your AWS credentials:

```powershell
aws sts get-caller-identity
```

### Error: User Already Exists

Import existing user into state:

```powershell
terraform import aws_iam_user.users[\"Michael\"] mscott
```

Or delete the existing user:

```powershell
aws iam delete-login-profile --user-name mscott
aws iam delete-user --user-name mscott
```

### View Terraform State

```powershell
terraform state list
terraform state show aws_iam_user.users[\"Michael\"]
```

## Best Practices

✅ **Use Remote State** - S3 backend with versioning enabled  
✅ **Consistent Naming** - Lowercase usernames with predictable format  
✅ **Metadata as Tags** - Store user attributes as searchable tags  
✅ **Password Reset** - Force password change on first login  
✅ **Data-Driven** - CSV file as single source of truth  
✅ **Idempotent** - Safe to run multiple times  

## Security Considerations

⚠️ **Important:**
- Users require password reset on first login
- Consider implementing MFA requirements
- Review IAM policies before attaching to groups
- Don't commit `terraform.tfstate` to version control
- Use AWS SSO for production environments
- Enable CloudTrail for audit logging

## Next Steps

1. **Add IAM Policies** - Attach appropriate policies to groups
2. **Enable MFA** - Require multi-factor authentication
3. **Set Up AWS SSO** - For better user management in production
4. **Add More Attributes** - Extend CSV with email, phone, etc.
5. **Automate Onboarding** - Integrate with HR systems

## Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform Functions](https://www.terraform.io/language/functions)
- [Complete Demo Guide](./DEMO_GUIDE.md)

## Success! ✅

Your AWS IAM infrastructure is now managed as code. You can:
- Add new users by editing the CSV
- Modify group memberships by changing user attributes
- Version control all changes
- Replicate this setup across multiple AWS accounts

Happy Terraforming! 🚀
