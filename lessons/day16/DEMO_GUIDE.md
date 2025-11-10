# AWS IAM User Management with Terraform - Demo Guide

## Overview
This demo shows how to manage AWS IAM users, groups, and group memberships using Terraform. It's an AWS equivalent of Azure AD user management, demonstrating Infrastructure as Code (IaC) best practices.

## What This Demo Does

1. **Retrieves AWS Account Information** - Gets your current AWS Account ID
2. **Reads User Data from CSV** - Loads user information from a CSV file
3. **Creates IAM Users** - Automatically creates IAM users with proper naming conventions
4. **Sets Up Login Profiles** - Configures console access with password reset requirement
5. **Creates IAM Groups** - Sets up organizational groups (Education, Managers, Engineers)
6. **Manages Group Memberships** - Automatically assigns users to appropriate groups

## Prerequisites

### Required Tools
- Terraform (v1.0+)
- AWS CLI configured with appropriate credentials
- AWS Account with IAM permissions

### AWS Permissions Required
Your AWS credentials need the following permissions:
- `iam:CreateUser`
- `iam:CreateGroup`
- `iam:CreateLoginProfile`
- `iam:AddUserToGroup`
- `iam:TagUser`
- `iam:GetUser`
- `iam:ListUsers`
- `s3:ListBucket` (for backend)
- `s3:GetObject` (for backend)
- `s3:PutObject` (for backend)

## File Structure

```
day16/
├── backend.tf          # S3 backend configuration for state management
├── provider.tf         # AWS provider configuration
├── versions.tf         # Terraform version and required providers
├── main.tf            # Main user creation logic
├── groups.tf          # IAM groups and membership management
├── users.csv          # User data source
└── DEMO_GUIDE.md      # This file
```

## Step-by-Step Demo Guide

### Step 1: Setup AWS Backend (One-time setup)

First, create an S3 bucket for storing Terraform state:

```powershell
# Create S3 bucket (replace with your unique bucket name)
aws s3 mb s3://my-terraform-state-bucket-piyushsachdeva --region us-east-1

# Enable versioning (recommended)
aws s3api put-bucket-versioning --bucket my-terraform-state-bucket-piyushsachdeva --versioning-configuration Status=Enabled
```

**Note:** The bucket name in `backend.tf` should match the bucket you created.

### Step 2: Review the User Data

Open `users.csv` and review the user data. The CSV contains:
- `first_name`: User's first name
- `last_name`: User's last name
- `department`: Department (Education, Sales, HR, etc.)
- `job_title`: Job title

Example:
```csv
first_name,last_name,department,job_title
Michael,Scott,Education,Regional Manager
Dwight,Schrute,Sales,Assistant to the Regional Manager
```

### Step 3: Initialize Terraform

Initialize Terraform to download providers and set up the backend:

```powershell
terraform init
```

**What happens:**
- Downloads AWS provider
- Configures S3 backend
- Creates `.terraform` directory

### Step 4: Review the Plan

See what resources Terraform will create:

```powershell
terraform plan
```

**Expected output:**
- 26 IAM users to be created
- 26 IAM login profiles to be created
- 3 IAM groups to be created
- 3 IAM group memberships to be created
- **Total: 58 resources**

### Step 5: Apply the Configuration

Create all the resources:

```powershell
terraform apply
```

Type `yes` when prompted, or use:

```powershell
terraform apply -auto-approve
```

**What gets created:**

1. **IAM Users** - Username format: `{first_initial}{lastname}` (e.g., `mscott`)
2. **Login Profiles** - Console access enabled with auto-generated passwords
3. **User Tags** - DisplayName, Department, and JobTitle stored as tags
4. **IAM Groups:**
   - Education
   - Managers
   - Engineers
5. **Group Memberships** - Users automatically assigned based on their attributes

### Step 6: Verify in AWS Console

1. Open the [IAM Console](https://console.aws.amazon.com/iam/)
2. Navigate to **Users** - You should see all 26 users
3. Navigate to **User groups** - You should see the 3 groups
4. Click on each group to see its members

### Step 7: View Outputs

See the created resources:

```powershell
# View account ID
terraform output account_id

# View all user names
terraform output user_names

# View password information (sensitive)
terraform output user_passwords
```

### Step 8: How to Log In as a Created User

**Before users can log in, you need to set their initial passwords. Here's the complete process:**

#### A. Get Your AWS Account ID

```powershell
# Get your AWS Account ID
terraform output account_id

# Or use AWS CLI
aws sts get-caller-identity --query Account --output text
```

Example output: `038806790653`

#### B. Set a Password for a User (Do this first!)

**Option 1: Using AWS Console (Easiest)**
1. Open [IAM Console](https://console.aws.amazon.com/iam/)
2. Click on **Users** in the left sidebar
3. Select a user (e.g., `mscott`)
4. Click the **Security credentials** tab
5. Scroll to **Console sign-in** section
6. Click **Manage** button
7. Choose **Enable console access**
8. Select **Custom password** and enter: `TempPassword123!`
9. ✅ Check **User must create a new password at next sign-in**
10. Click **Apply**
11. Copy the password (you'll need it for login)

**Option 2: Using AWS CLI (Faster for multiple users)**
```powershell
# Set password for Michael Scott (username: mscott)
aws iam create-login-profile --user-name mscott --password "TempPassword123!" --password-reset-required

# Set passwords for multiple users
aws iam create-login-profile --user-name dschrute --password "TempPassword123!" --password-reset-required
aws iam create-login-profile --user-name jhalpert --password "TempPassword123!" --password-reset-required
aws iam create-login-profile --user-name pbeesly --password "TempPassword123!" --password-reset-required
```

#### C. Log In to AWS Console

1. **Get the Sign-in URL:**
   ```
   https://YOUR_ACCOUNT_ID.signin.aws.amazon.com/console
   ```
   Replace `YOUR_ACCOUNT_ID` with your actual account ID (from Step A)
   
   Example: `https://038806790653.signin.aws.amazon.com/console`

2. **Or use the Account Alias URL (if configured):**
   ```
   https://your-company-name.signin.aws.amazon.com/console
   ```

3. **Enter Credentials:**
   - **IAM user name:** `mscott` (or whichever user you set password for)
   - **Password:** `TempPassword123!` (or the password you set)
   - Click **Sign in**

4. **Change Password (Required on First Login):**
   - AWS will prompt you to change the password
   - Enter the old password: `TempPassword123!`
   - Enter a new password (must meet AWS password policy)
   - Confirm the new password
   - Click **Confirm password change**

5. **You're In!** 🎉
   - You should now see the AWS Management Console
   - The user will have access based on their group memberships

#### D. Verify User's Group Memberships

Once logged in, you can verify which groups the user belongs to:

1. Click on your username in the top-right corner
2. Select **Security credentials**
3. Look for the **Groups** section to see which groups you're a member of

Example for `mscott`:
- Should be in **Education** group (Department = Education)
- Should be in **Managers** group (Job Title contains "Manager")

#### E. Test Multiple Users

To test different users, log out and repeat steps C-D with different usernames:

| Username | Full Name | Department | Groups |
|----------|-----------|------------|--------|
| `mscott` | Michael Scott | Education | Education, Managers |
| `dschrute` | Dwight Schrute | Sales | (none yet - add Sales group) |
| `jhalpert` | Jim Halpert | Sales | (none yet - add Sales group) |
| `pbeesly` | Pam Beesly | Reception | (none yet - add Reception group) |
| `dwallace` | David Wallace | Corporate | Managers |

#### F. Quick Testing Script (PowerShell)

Set passwords for all users at once:

```powershell
# Set password for all users (will fail if already set)
$users = @("mscott", "dschrute", "jhalpert", "pbeesly", "rhoward", "abernard", "rcalifornia", "shudson", "kmalone", "amartin", "omartinez", "pvance", "tflenderson", "kkapoor", "dphilbin", "cbratton", "mpalmer", "ehannon", "glewis", "jlevinson", "dwallace", "hflax", "cminer", "jbennett", "cgreen", "pmiller")

foreach ($user in $users) {
    try {
        aws iam create-login-profile --user-name $user --password "TempPassword123!" --password-reset-required
        Write-Host "✅ Password set for $user" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Password already exists for $user or error occurred" -ForegroundColor Yellow
    }
}

Write-Host "`n🔐 All users can now log in with password: TempPassword123!"
Write-Host "📝 They will be required to change it on first login"
Write-Host "🌐 Login URL: https://$(aws sts get-caller-identity --query Account --output text).signin.aws.amazon.com/console"
```

#### G. Troubleshooting Login Issues

**Error: "Your authentication information is incorrect"**
- ✅ Check that you're using the correct username (e.g., `mscott` not `Michael Scott`)
- ✅ Verify you've set a password for this user
- ✅ Ensure you're using the correct AWS Account ID in the URL

**Error: "Cannot find your AWS account"**
- ✅ Double-check the Account ID in the URL
- ✅ Try using: `https://console.aws.amazon.com/` and sign in as IAM user

**Error: "User does not exist"**
- ✅ Verify the user was created: `aws iam get-user --user-name mscott`
- ✅ Check Terraform state: `terraform state show aws_iam_user.users[\"Michael\"]`

**Password Policy Requirements:**
When changing password on first login, ensure it meets AWS password policy:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (!@#$%^&*)

## Understanding the Code

### main.tf - User Creation

```terraform
# Read CSV and convert to local variable
locals {
  users = csvdecode(file("users.csv"))
}

# Create users with for_each loop
resource "aws_iam_user" "users" {
  for_each = { for user in local.users : user.first_name => user }
  
  # Username: first initial + last name (lowercase)
  name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
  
  # Store metadata as tags
  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department"  = each.value.department
    "JobTitle"    = each.value.job_title
  }
}
```

**Key Concepts:**
- `csvdecode()` - Parses CSV into a list of maps
- `for_each` - Creates one resource per map entry
- `substr()` - Extracts first character for username
- `lower()` - Ensures consistent lowercase naming

### groups.tf - Group Management

```terraform
# Create group
resource "aws_iam_group" "education" {
  name = "Education"
  path = "/groups/"
}

# Add members with conditional logic
resource "aws_iam_group_membership" "education_members" {
  name  = "education-group-membership"
  group = aws_iam_group.education.name

  users = [
    for user in aws_iam_user.users : user.name 
    if user.tags.Department == "Education"
  ]
}
```

**Key Concepts:**
- Conditional `for` loop - Only includes users matching criteria
- Resource references - `aws_iam_user.users` references all created users
- Dynamic membership - Users automatically assigned based on tags

## Common Issues and Solutions

### Issue 1: Backend Access Denied
**Error:** `Error: Failed to get existing workspaces`

**Solution:**
```powershell
# Check AWS credentials
aws sts get-caller-identity

# Verify S3 bucket exists and you have access
aws s3 ls s3://my-terraform-state-bucket-piyushsachdeva
```

### Issue 2: User Already Exists
**Error:** `EntityAlreadyExists: User with name {username} already exists`

**Solution:**
```powershell
# Import existing user into state
terraform import aws_iam_user.users[\"Michael\"] mscott

# Or delete the existing user
aws iam delete-user --user-name mscott
```

### Issue 3: How to Get User Passwords
**Note:** AWS auto-generates passwords but doesn't return them without PGP encryption for security reasons.

**Solution - Option 1: Use AWS Console (Recommended)**
1. Go to [IAM Console](https://console.aws.amazon.com/iam/)
2. Click on **Users**
3. Select a user (e.g., `mscott`)
4. Click **Security credentials** tab
5. Under **Console sign-in**, click **Manage**
6. Choose **Enable console access** or **Create password**
7. You can either:
   - Generate a new password (AWS will show it once)
   - Set a custom password
8. Check **User must create a new password at next sign-in**
9. Click **Apply**

**Solution - Option 2: Use AWS CLI**
```powershell
# Set a temporary password for a specific user
aws iam create-login-profile --user-name mscott --password "TempPassword123!" --password-reset-required

# Or use AWS CLI to generate and retrieve password (shown only once)
aws iam create-login-profile --user-name mscott --password-reset-required --generate-cli-skeleton
```

**Solution - Option 3: Send Password Reset Email (If email is configured)**
```powershell
# User can reset password via AWS console login page
# Click "Forgot password" on: https://YOUR_ACCOUNT_ID.signin.aws.amazon.com/console
```

**What the current setup does:**
- ✅ Creates users with console access enabled
- ✅ Auto-generates secure passwords
- ✅ Forces password change on first login
- ❌ Does NOT expose passwords (security best practice)

**To enable password retrieval in Terraform (Advanced):**
You would need to configure PGP encryption in `main.tf` - see section below.

---

## 🔐 Advanced: Using PGP Encryption for Password Management (Optional)

**⚠️ Note:** This section is for advanced users who want production-grade security. Skip this if you're just learning Terraform basics.

### Why Use PGP Encryption?

**Current Approach (Simple):**
- ❌ Passwords not returned by Terraform
- ✅ Must be set manually via console/CLI
- ✅ Simple and beginner-friendly
- ✅ Good for demos and learning

**PGP Approach (Advanced):**
- ✅ Passwords encrypted in Terraform state
- ✅ Can retrieve passwords via Terraform output
- ✅ Automated password distribution
- ✅ Production-ready security
- ❌ Requires GPG setup and knowledge
- ❌ More complex workflow

### When to Use PGP:

✅ **Use PGP if:**
- Managing production IAM users at scale
- Need automated password distribution
- Have GPG infrastructure in place
- Team familiar with GPG/encryption
- Compliance requires encrypted secrets

❌ **Don't use PGP if:**
- Just learning Terraform (keep it simple!)
- Doing a quick demo or POC
- Team unfamiliar with GPG
- Using AWS SSO instead (recommended for production)

### Implementation Guide

#### Step 1: Install GPG

**Windows:**
```powershell
# Install using Chocolatey
choco install gpg4win

# Or download from: https://gpg4win.org/
```

**Linux:**
```bash
sudo apt-get install gnupg  # Ubuntu/Debian
sudo yum install gnupg2     # RHEL/CentOS
```

**macOS:**
```bash
brew install gnupg
```

#### Step 2: Generate a GPG Key

```powershell
# Generate a new GPG key
gpg --gen-key

# Follow the prompts:
# - Real name: Terraform Demo
# - Email: terraform@example.com
# - Passphrase: (choose a strong passphrase)
```

#### Step 3: Export Your Public Key

```powershell
# List your keys to find the key ID
gpg --list-keys

# Export the public key (base64 encoded)
gpg --export terraform@example.com | base64 > public_key.txt

# Or get it directly
$pgpKey = gpg --export terraform@example.com | base64 -w 0
```

#### Step 4: Update main.tf

Replace the login profile section in `main.tf`:

```terraform
# Create IAM user login profile (password) with PGP encryption
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  pgp_key                 = "keybase:your_keybase_username"  # Option 1: Use Keybase
  # OR
  # pgp_key               = file("public_key.txt")          # Option 2: Use local file
  
  password_reset_required = true
}

# Output encrypted passwords
output "user_passwords_encrypted" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => profile.encrypted_password
  }
  sensitive = true
}

# Output key fingerprint for verification
output "key_fingerprint" {
  value = aws_iam_user_login_profile.users["Michael"].key_fingerprint
}
```

#### Step 5: Apply and Retrieve Passwords

```powershell
# Apply Terraform
terraform apply

# Get encrypted passwords
terraform output -json user_passwords_encrypted | ConvertFrom-Json

# Decrypt a specific password
$encrypted = terraform output -json user_passwords_encrypted | ConvertFrom-Json | Select-Object -ExpandProperty Michael
echo $encrypted | base64 -d | gpg -d
```

#### Step 6: Decrypt Passwords

**Decrypt a single password:**
```powershell
# Get encrypted password for mscott
$encryptedPassword = (terraform output -json user_passwords_encrypted | ConvertFrom-Json).Michael

# Decode and decrypt
echo $encryptedPassword | base64 -d | gpg --decrypt
```

**Decrypt all passwords (PowerShell script):**
```powershell
# Get all encrypted passwords
$passwords = terraform output -json user_passwords_encrypted | ConvertFrom-Json

# Decrypt each one
foreach ($user in $passwords.PSObject.Properties) {
    $username = $user.Name
    $encrypted = $user.Value
    
    Write-Host "`n👤 User: $username"
    Write-Host "🔓 Password: " -NoNewline
    
    # Decrypt the password
    $decrypted = echo $encrypted | base64 -d | gpg --decrypt 2>$null
    Write-Host $decrypted -ForegroundColor Green
}
```

### Using Keybase (Easier Alternative)

Keybase provides public PGP keys via a simple username reference:

#### Step 1: Create Keybase Account
1. Go to https://keybase.io
2. Create a free account
3. Upload your PGP key or generate one in Keybase

#### Step 2: Update main.tf
```terraform
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  pgp_key                 = "keybase:your_keybase_username"  # Much simpler!
  password_reset_required = true
}
```

#### Step 3: Decrypt with Keybase
```powershell
# Keybase automatically handles decryption
terraform output user_passwords_encrypted | keybase pgp decrypt
```

### Complete Example with PGP

Here's a complete working example:

**main.tf:**
```terraform
# Get AWS Account ID
data "aws_caller_identity" "current" {}

# Read users from CSV
locals {
  users = csvdecode(file("users.csv"))
}

# Create IAM users
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

# Create login profiles with PGP encryption
resource "aws_iam_user_login_profile" "users" {
  for_each = aws_iam_user.users

  user                    = each.value.name
  pgp_key                 = file("public_key.txt")  # Your base64-encoded public key
  password_reset_required = true
}

# Output encrypted passwords
output "encrypted_passwords" {
  description = "Encrypted passwords for all users"
  value = {
    for user, profile in aws_iam_user_login_profile.users :
    user => {
      username           = profile.user
      encrypted_password = profile.encrypted_password
      key_fingerprint    = profile.key_fingerprint
    }
  }
  sensitive = true
}
```

**decrypt_passwords.ps1:**
```powershell
#!/usr/bin/env pwsh
# Script to decrypt all user passwords

Write-Host "🔐 Decrypting IAM User Passwords`n" -ForegroundColor Cyan

# Get encrypted passwords from Terraform
$passwords = terraform output -json encrypted_passwords | ConvertFrom-Json

# Create results file
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$outputFile = "decrypted_passwords_$timestamp.txt"

Write-Host "Decrypting passwords..." -ForegroundColor Yellow
Write-Host "Output will be saved to: $outputFile`n"

foreach ($user in $passwords.PSObject.Properties) {
    $username = $user.Value.username
    $encrypted = $user.Value.encrypted_password
    
    Write-Host "👤 User: $username" -ForegroundColor Green
    
    try {
        # Decode base64 and decrypt with GPG
        $decrypted = [System.Text.Encoding]::UTF8.GetString(
            [System.Convert]::FromBase64String($encrypted)
        ) | gpg --decrypt 2>$null
        
        Write-Host "   Password: $decrypted`n" -ForegroundColor White
        
        # Save to file
        Add-Content -Path $outputFile -Value "$username : $decrypted"
        
    } catch {
        Write-Host "   ❌ Failed to decrypt`n" -ForegroundColor Red
    }
}

Write-Host "`n✅ Complete! Passwords saved to: $outputFile" -ForegroundColor Green
Write-Host "⚠️  Remember to delete this file securely when done!" -ForegroundColor Yellow
```

### Pros and Cons Comparison

| Feature | Without PGP (Current) | With PGP (Advanced) |
|---------|----------------------|---------------------|
| **Setup Complexity** | ⭐ Simple | ⭐⭐⭐ Complex |
| **Password Retrieval** | Manual (Console/CLI) | Automated (Terraform) |
| **Security** | ⭐⭐⭐ Good | ⭐⭐⭐⭐⭐ Excellent |
| **State File** | Passwords not stored | Encrypted passwords |
| **Dependencies** | None | GPG/Keybase required |
| **Learning Curve** | ⭐ Easy | ⭐⭐⭐⭐ Steep |
| **Production Ready** | ⭐⭐⭐ Yes | ⭐⭐⭐⭐⭐ Yes |
| **Demo Friendly** | ⭐⭐⭐⭐⭐ Very | ⭐⭐ Not really |

### Recommendation

**For this demo:** Stick with the current approach (no PGP)
- ✅ Easier to understand and follow
- ✅ Focuses on Terraform core concepts
- ✅ No additional tools required
- ✅ Better for learning

**For production:** Consider PGP or better yet, AWS SSO
- Use PGP if you need IAM users with automated provisioning
- Consider AWS SSO/Identity Center for better user management
- Use AWS Secrets Manager for application passwords
- Implement MFA for all users

### Additional Resources

- [Terraform aws_iam_user_login_profile Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile)
- [GPG/PGP Encryption Guide](https://gnupg.org/documentation/)
- [Keybase for PGP](https://keybase.io/docs/command_line)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS IAM Identity Center (SSO)](https://aws.amazon.com/iam/identity-center/)

---

## Cleanup

To remove all created resources:

```powershell
terraform destroy
```

**⚠️ Warning:** This will delete all users, groups, and memberships. Type `yes` to confirm.

## Extending the Demo

### Add More Departments
Edit `groups.tf` to add new groups:

```terraform
resource "aws_iam_group" "sales" {
  name = "Sales"
  path = "/groups/"
}

resource "aws_iam_group_membership" "sales_members" {
  name  = "sales-group-membership"
  group = aws_iam_group.sales.name

  users = [
    for user in aws_iam_user.users : user.name 
    if user.tags.Department == "Sales"
  ]
}
```

### Attach IAM Policies to Groups

```terraform
# Attach ReadOnlyAccess to Education group
resource "aws_iam_group_policy_attachment" "education_readonly" {
  group      = aws_iam_group.education.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
```

### Add More User Attributes

Edit `users.csv` to include additional columns:
```csv
first_name,last_name,department,job_title,email,phone
Michael,Scott,Education,Regional Manager,mscott@example.com,555-0100
```

Update `main.tf` to use the new attributes:
```terraform
tags = {
  "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
  "Department"  = each.value.department
  "JobTitle"    = each.value.job_title
  "Email"       = each.value.email
  "Phone"       = each.value.phone
}
```

## Best Practices Demonstrated

1. **Separation of Concerns** - Backend, provider, and resource definitions in separate files
2. **Data-Driven Configuration** - CSV file as single source of truth
3. **Consistent Naming** - Lowercase usernames with predictable format
4. **Metadata as Tags** - User attributes stored as searchable tags
5. **State Management** - Remote S3 backend with versioning
6. **Idempotency** - Can run multiple times with same result
7. **Conditional Logic** - Dynamic group membership based on attributes

## Security Considerations

⚠️ **Important:**
- Users are created with auto-generated passwords
- Password reset is required on first login
- Consider implementing MFA requirements
- Review IAM policies before attaching to groups
- Don't commit `terraform.tfstate` to version control
- Use AWS Secrets Manager for sensitive data in production
- Consider using AWS SSO instead of IAM users for production

## Troubleshooting

### View Terraform State
```powershell
terraform show
```

### List All Resources
```powershell
terraform state list
```

### Check Specific Resource
```powershell
terraform state show aws_iam_user.users[\"Michael\"]
```

### Refresh State
```powershell
terraform refresh
```

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform Functions Reference](https://www.terraform.io/language/functions)

## Demo Presentation Flow

When presenting this demo, follow this narrative:

1. **Problem Statement** (2 min)
   - Manual user creation is time-consuming and error-prone
   - Need consistent, repeatable user provisioning
   - Want to manage users as code

2. **Show the CSV File** (1 min)
   - Simple spreadsheet format
   - Can be maintained by HR or IT
   - Single source of truth

3. **Explain the Code** (3 min)
   - Walk through `main.tf` - reading CSV, creating users
   - Show `groups.tf` - dynamic group membership
   - Highlight use of `for_each` and conditionals

4. **Run the Demo** (5 min)
   - `terraform init` - show backend setup
   - `terraform plan` - explain what will be created
   - `terraform apply` - watch resources being created
   - Show outputs

5. **Verify in Console** (2 min)
   - Open IAM console
   - Show created users with tags
   - Show groups and memberships

6. **Discuss Extensions** (2 min)
   - How to add policies
   - How to add more groups
   - How to integrate with other systems

**Total: ~15 minutes**

## Conclusion

This demo showcases the power of Infrastructure as Code for IAM management. Key takeaways:

✅ Terraform can manage AWS IAM resources programmatically
✅ CSV files provide a simple, maintainable data source
✅ Dynamic resource creation with loops reduces code duplication
✅ Conditional logic enables sophisticated membership rules
✅ State management ensures consistency across deployments

Happy Terraforming! 🚀
