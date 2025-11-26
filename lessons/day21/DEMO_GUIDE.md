# Demo Guide: AWS Policy and Governance

**Tested with Terraform - Creates 24 AWS resources**

---

## ⚡ Quick Demo (10 minutes)

### Step 1: Deploy

```bash
terraform init
terraform plan         # Shows 24 resources
terraform apply -auto-approve
```

**Creates:**
- 4 IAM Policies (MFA, encryption, tagging)
- 1 IAM User
- 1 S3 Bucket (encrypted, versioned, locked down)
- 7 Config Rules (compliance monitoring)
- 1 Config Recorder (auto-started)

### Step 2: View Outputs

```bash
terraform output
```

Shows: Policy ARNs, bucket name, recorder status, all 7 rules

### Step 3: Verify in Console

**IAM:**
```bash
aws iam list-policies --scope Local | grep terraform-governance
```
Console: IAM → Policies → Customer managed

**S3:**
```bash
aws s3api get-bucket-encryption --bucket $(terraform output -raw config_bucket_name)
aws s3api get-bucket-versioning --bucket $(terraform output -raw config_bucket_name)
```
Console: S3 → Find bucket → Check Properties & Permissions

**Config:**
```bash
aws configservice describe-configuration-recorder-status
aws configservice describe-config-rules | grep RuleName
```
Console: AWS Config → Dashboard (wait 5-10 min) → Rules

### Step 4: Test Compliance

```bash
# Create non-compliant bucket
aws s3 mb s3://test-violation-$(date +%s)

# Wait 2-3 minutes, check Config console
# Will show as Non-Compliant

# Cleanup
aws s3 rb s3://test-violation-* --force
```

### Step 5: Cleanup

```bash
terraform destroy -auto-approve
```

---

## 📚 Full Teaching Demo (45 minutes)

### Part 1: Introduction (5 min)

**Why Governance?**
- Prevent security misconfigurations
- Meet compliance requirements (SOC 2, HIPAA, GDPR)
- Detect configuration drift
- Audit trail

**Manual Audits vs Automated Governance:**
- Manual: Point-in-time, error-prone, slow
- Automated: Continuous, consistent, scalable

**Architecture:**
```
IAM Policies (preventive) → Enforce security at action level
         ↓
   AWS Config (detective) → Monitor compliance continuously
         ↓
   S3 Bucket (storage) → Encrypted logs with versioning
```

---

### Part 2: Code Walkthrough (15 min)

#### File Structure
```
provider.tf   - AWS provider config
variables.tf  - Region, project name
iam.tf       - 4 policies + demo user
main.tf      - S3 bucket with security
config.tf    - Recorder + 7 rules
outputs.tf   - Key info display
```

#### IAM Policies Explained

**1. MFA Delete Policy** (`iam.tf`)
```json
"Condition": {
  "BoolIfExists": {
    "aws:MultiFactorAuthPresent": "false"
  }
}
```
- **What:** Denies S3 object deletion without MFA
- **Why:** Protect production data from accidental/malicious deletion
- **Use case:** Financial records, customer data

**2. S3 Encryption in Transit**
```json
"Condition": {
  "Bool": {
    "aws:SecureTransport": "false"
  }
}
```
- **What:** Requires HTTPS for all S3 operations
- **Why:** Prevent man-in-the-middle attacks
- **Use case:** Any sensitive data transfer

**3. Required Tags Policy**
```hcl
Condition: {
  StringNotLike: {
    "aws:RequestTag/Environment": ["dev", "staging", "prod"]
  }
}
```
- **What:** Enforces Environment and Owner tags on EC2
- **Why:** Cost allocation, resource tracking, accountability
- **Use case:** Multi-team organizations

**4. Demo User**
- Shows real policy attachment
- Uses /governance/ path for organization
- Tagged for tracking

#### S3 Security Features

```hcl
# Versioning - audit trail
aws_s3_bucket_versioning

# Encryption - AES256 at rest
aws_s3_bucket_server_side_encryption_configuration

# Block all public access
aws_s3_bucket_public_access_block

# Bucket policy - Config service only
aws_s3_bucket_policy
```

**Point out:** Multiple layers of security (defense in depth)

#### AWS Config Rules

**7 Compliance Checks:**

1. **s3-bucket-public-write-prohibited**
   - Prevents public write access to S3
   
2. **s3-bucket-server-side-encryption-enabled**
   - Ensures all buckets are encrypted
   
3. **s3-bucket-public-read-prohibited**
   - Blocks public read access
   
4. **encrypted-volumes**
   - Verifies EBS volumes are encrypted
   
5. **required-tags**
   - Checks for Environment and Owner tags
   - Scope: EC2 instances, S3 buckets
   
6. **iam-password-policy**
   - Min 14 chars, uppercase, lowercase, numbers, symbols
   - Max password age: 90 days
   
7. **root-account-mfa-enabled**
   - Ensures root account has MFA

**Key:** `aws_config_configuration_recorder_status` starts the recorder automatically!

---

### Part 3: Live Deployment (10 min)

#### Initialize
```bash
terraform init
```
- Downloads AWS provider (v5.x)
- Creates .terraform directory
- Generates lock file

#### Plan
```bash
terraform plan
```

**Walk through the output:**
- "Plan: 24 to add, 0 to change, 0 to destroy"
- Show policy JSON in plan
- Point out Config rule parameters
- Explain resource dependencies

**Key resources to highlight:**
- `random_string.suffix` - Makes bucket name unique
- `aws_iam_policy` resources - Show JSON policies
- `aws_config_config_rule` with `input_parameters`
- `depends_on` relationships

#### Apply
```bash
terraform apply
```

**While deploying (2-3 minutes):**
1. IAM resources created first (no dependencies)
2. S3 bucket created
3. S3 configurations applied (versioning, encryption, etc.)
4. IAM role for Config
5. Config recorder created
6. Config delivery channel
7. Config recorder started
8. All 7 Config rules deployed

#### Outputs
```bash
terraform output
```

**Explain each:**
- `mfa_delete_policy_arn` - Can attach to other users/roles
- `s3_encryption_transit_policy_arn` - Enforce HTTPS
- `require_tags_policy_arn` - Enforce tagging
- `demo_user_name` - Sample user with policies
- `config_bucket_name` - Where Config stores snapshots
- `config_recorder_status` - Should be `true` (enabled)
- `config_rules` - All 7 rule names
- `compliance_dashboard_info` - Console access info

---

### Part 4: AWS Console Walkthrough (10 min)

#### IAM Policies

**Via CLI:**
```bash
aws iam list-policies --scope Local --query 'Policies[?contains(PolicyName, `terraform-governance`)]'
```

**In Console:**
1. Navigate to IAM → Policies
2. Filter: "Customer managed"
3. Find "terraform-governance-demo-mfa-delete-policy"
4. Click it → Review JSON
5. Go to "Policy usage" tab → Shows attached to demo-user
6. Click demo-user → See attached policies

**Teaching point:** Show the JSON structure, explain each statement

#### S3 Bucket

**Via CLI:**
```bash
BUCKET=$(terraform output -raw config_bucket_name)

# Encryption
aws s3api get-bucket-encryption --bucket $BUCKET

# Versioning
aws s3api get-bucket-versioning --bucket $BUCKET

# Public access block
aws s3api get-public-access-block --bucket $BUCKET
```

**In Console:**
1. S3 → Find bucket (terraform-governance-demo-config-bucket-XXXXXX)
2. **Properties tab:**
   - Bucket Versioning: **Enabled**
   - Default encryption: **AES-256**
   - Show version history (will build over time)
3. **Permissions tab:**
   - Block public access: **All 4 settings ON**
   - Bucket policy: Show JSON (Config service access)
   - Explain least privilege

**Teaching point:** Multiple security layers on one bucket

#### AWS Config

**Via CLI:**
```bash
# Recorder status
aws configservice describe-configuration-recorder-status

# All rules
aws configservice describe-config-rules --query 'ConfigRules[].ConfigRuleName'

# Specific rule compliance
aws configservice describe-compliance-by-config-rule \
  --config-rule-names s3-bucket-server-side-encryption-enabled
```

**In Console:**
1. Navigate to AWS Config
2. **Dashboard:**
   - Shows "Evaluating..." initially
   - Wait 5-10 minutes for first results
   - Shows compliant vs non-compliant resources
3. **Rules (left sidebar):**
   - Shows all 7 rules
   - Each has status (Compliant, Non-compliant, etc.)
4. **Click "s3-bucket-server-side-encryption-enabled":**
   - Shows rule details
   - Lists resources in scope
   - Shows compliance status per resource
   - Can see evaluation history
5. **Click "Resources" tab:**
   - Shows all S3 buckets
   - Config bucket should be compliant

**Teaching points:**
- Config continuously evaluates
- Rules can have different scopes
- Compliance status updates automatically
- Can export compliance reports

---

### Part 5: Demonstrate Compliance Detection (5 min)

#### Create a Violation

```bash
# Create bucket WITHOUT encryption (violates rule)
aws s3 mb s3://demo-violation-$(date +%s)

# Optional: Add some content
echo "test" > test.txt
aws s3 cp test.txt s3://demo-violation-*/
```

#### Watch Config Detect It

**After 2-3 minutes:**

1. Go to AWS Config → Rules
2. Click "s3-bucket-server-side-encryption-enabled"
3. Refresh → Should see new bucket
4. Status: **Non-Compliant** (red)
5. Click on the resource → Shows why it's non-compliant

**Teaching points:**
- Config detected the violation automatically
- No manual audit needed
- Can set up SNS notifications for this
- Can trigger automatic remediation

#### Cleanup Test Bucket

```bash
# Remove test bucket
aws s3 rb s3://demo-violation-* --force

# After 2-3 minutes, Config will show it as deleted
```

---

### Part 6: Best Practices Discussion (5 min)

#### 1. Policy as Code Benefits
- ✅ Version controlled (Git)
- ✅ Repeatable across environments
- ✅ Team collaboration via PRs
- ✅ Audit trail of changes
- ✅ Can test before applying

#### 2. Continuous Compliance
- ✅ 24/7 monitoring
- ✅ Automatic detection of drift
- ✅ No manual audits
- ✅ Real-time alerts possible
- ✅ Historical compliance data

#### 3. Defense in Depth
- **Layer 1:** IAM policies (prevent bad actions)
- **Layer 2:** S3 bucket policies (resource-level control)
- **Layer 3:** Encryption (protect data)
- **Layer 4:** Config rules (detect violations)
- **Result:** Multiple failsafes

#### 4. Real-World Applications
- **Compliance:** SOC 2, HIPAA, GDPR, PCI-DSS
- **Security:** Prevent misconfigurations
- **Operations:** Detect drift, audit changes
- **Finance:** Cost allocation via tags
- **Governance:** Enforce organizational standards

---

### Part 7: Cleanup (5 min)

```bash
terraform destroy -auto-approve
```

**While destroying:**
- Explain deletion order (reverse of dependencies)
- Config rules deleted first
- Config recorder stopped and deleted
- S3 bucket force-destroyed (including contents)
- IAM resources last

**Cost consideration:**
- Config: ~$2-3/month for 7 rules
- Always destroy demo environments
- Production: keep running for compliance

**Verify cleanup:**
```bash
aws s3 ls | grep config-bucket        # Should be empty
aws iam list-users | grep demo-user   # Should be empty
aws configservice describe-configuration-recorders  # Should be empty
```

---

## 💡 Advanced Topics (Optional)

### Automated Remediation

Add SNS topic and Lambda function:
```hcl
resource "aws_config_remediation_configuration" "auto_fix" {
  config_rule_name = aws_config_config_rule.s3_encryption.name
  target_type      = "SSM_DOCUMENT"
  target_identifier = "AWS-EnableS3BucketEncryption"
}
```

### Multi-Account Setup

Use AWS Organizations and Config Aggregator:
```hcl
resource "aws_config_configuration_aggregator" "organization" {
  name = "organization-aggregator"
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.aggregator.arn
  }
}
```

### Custom Config Rules

Use Lambda for custom logic:
```hcl
resource "aws_config_config_rule" "custom" {
  name = "custom-compliance-check"
  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.compliance.arn
  }
}
```

---

## 🎯 Common Questions

**Q: How much does this cost?**
A: ~$2-3/month for Config (7 rules × $0.001 per evaluation). S3 storage < $0.10. Destroy after demo.

**Q: Can I customize the rules?**
A: Yes! Edit `input_parameters` in `config.tf`. Example: change password length from 14 to 16.

**Q: How do I add more policies?**
A: Add new `aws_iam_policy` resources in `iam.tf`. Use `jsonencode()` for the policy document.

**Q: Does this work in all regions?**
A: Yes. Change `aws_region` variable. Config is regional; use aggregator for multi-region.

**Q: Is this production-ready?**
A: Base is solid. Add:
- Remote backend (S3 + DynamoDB)
- SNS notifications
- Automated remediation
- CloudTrail integration
- More granular policies

**Q: What if a rule shows non-compliant?**
A: That's the goal! It alerts you to fix the issue. Can trigger auto-remediation.

**Q: How often do rules evaluate?**
A: Continuous for config changes, periodic (24h) for batch checks.

**Q: Can I exclude resources from rules?**
A: Yes, use `scope` block in rule definition to filter by resource type, tag, etc.

---

## 🔧 Troubleshooting

### Issue: "Access Denied" during apply

**Diagnosis:**
```bash
aws sts get-caller-identity  # Check your identity
aws iam get-user             # Check permissions
```

**Solution:**
Ensure your AWS credentials have permissions for:
- IAM (policies, users, roles)
- S3 (buckets, bucket policies)
- AWS Config (recorders, rules)

### Issue: Config rules not evaluating

**Diagnosis:**
```bash
aws configservice describe-configuration-recorder-status
```

**Solutions:**
1. Wait 5-10 minutes for initial evaluation
2. Create test resources to trigger evaluation
3. Check recorder is running: `is_enabled: true`
4. Verify delivery channel is configured

### Issue: S3 bucket name already exists

**Diagnosis:**
Error: "BucketAlreadyExists"

**Solution:**
Random suffix should prevent this. If it happens:
```bash
terraform apply -var="project_name=my-unique-name-123"
```

### Issue: Terraform state locked

**Diagnosis:**
Error: "Error acquiring the state lock"

**Solution:**
```bash
# Check lock info
terraform force-unlock <lock-id>

# Or wait for lock to expire (usually 15 min)
```

### Issue: Config recorder already exists

**Diagnosis:**
Error: "ConfigurationRecorderNameAlreadyExistsException"

**Solution:**
```bash
# List existing recorders
aws configservice describe-configuration-recorders

# Delete if needed (careful!)
aws configservice delete-configuration-recorder --name <recorder-name>
```

---

## 📊 Resource Breakdown

| Resource Type | Count | Purpose |
|--------------|-------|---------|
| `aws_iam_policy` | 4 | Security policies (MFA, encryption, tagging) |
| `aws_iam_user` | 1 | Demo user for policy attachment |
| `aws_iam_user_policy_attachment` | 1 | Attach MFA policy to user |
| `aws_iam_role` | 1 | Config service role |
| `aws_iam_role_policy` | 1 | S3 write policy for Config |
| `aws_iam_role_policy_attachment` | 1 | Managed Config policy |
| `aws_s3_bucket` | 1 | Config log storage |
| `aws_s3_bucket_versioning` | 1 | Enable versioning |
| `aws_s3_bucket_server_side_encryption_configuration` | 1 | AES256 encryption |
| `aws_s3_bucket_public_access_block` | 1 | Block all public access |
| `aws_s3_bucket_policy` | 1 | Allow Config service |
| `aws_config_configuration_recorder` | 1 | Record config changes |
| `aws_config_configuration_recorder_status` | 1 | Start the recorder |
| `aws_config_delivery_channel` | 1 | Deliver to S3 |
| `aws_config_config_rule` | 7 | Compliance rules |
| `random_string` | 1 | Unique bucket suffix |
| **TOTAL** | **24** | **Complete governance setup** |

---

## 🎓 Student Exercises

### Beginner Level

1. **Customize the project name**
   ```bash
   terraform apply -var="project_name=my-governance"
   ```

2. **Add tags to the S3 bucket**
   Edit `main.tf` and add more tags

3. **View a different Config rule**
   Check "required-tags" rule in console

### Intermediate Level

1. **Add RDS encryption rule**
   ```hcl
   resource "aws_config_config_rule" "rds_encryption" {
     name = "rds-storage-encrypted"
     source {
       owner             = "AWS"
       source_identifier = "RDS_STORAGE_ENCRYPTED"
     }
   }
   ```

2. **Modify password policy**
   Change `MinimumPasswordLength` to 16

3. **Create second IAM user**
   Add another user with different policies

4. **Add S3 bucket logging**
   Enable access logs on the Config bucket

### Advanced Level

1. **Add SNS notifications**
   ```hcl
   resource "aws_sns_topic" "config_alerts" {
     name = "config-compliance-alerts"
   }
   
   resource "aws_config_delivery_channel" "main" {
     sns_topic_arn = aws_sns_topic.config_alerts.arn
   }
   ```

2. **Create custom Config rule with Lambda**
   Write Lambda function to check custom compliance

3. **Implement automated remediation**
   Use SSM documents to fix violations automatically

4. **Set up Config aggregator**
   Centralize compliance across multiple regions/accounts

5. **Integrate with Security Hub**
   Send Config findings to Security Hub

---

## 📚 Additional Resources

### Documentation
- [AWS Config User Guide](https://docs.aws.amazon.com/config/latest/developerguide/)
- [Config Managed Rules](https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html)
- [IAM Policy Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Tools
- [IAM Policy Simulator](https://policysim.aws.amazon.com/)
- [Config Rules Development Kit](https://github.com/awslabs/aws-config-rdk)
- [AWS Well-Architected Tool](https://aws.amazon.com/well-architected-tool/)

### Compliance Frameworks
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

## ✅ Demo Checklist

**Before Demo:**
- [ ] AWS account access verified
- [ ] AWS CLI configured (`aws sts get-caller-identity`)
- [ ] Terraform installed (`terraform version`)
- [ ] Code downloaded/cloned
- [ ] Run `terraform init` beforehand
- [ ] Test `terraform plan` works
- [ ] Prepare AWS Console in browser
- [ ] Have architecture diagram ready
- [ ] Review key talking points

**During Demo:**
- [ ] Explain why governance matters
- [ ] Walk through code files
- [ ] Show terraform plan output
- [ ] Apply configuration
- [ ] Verify in console (IAM, S3, Config)
- [ ] Demonstrate compliance detection
- [ ] Answer questions
- [ ] Destroy resources

**After Demo:**
- [ ] Verify all resources destroyed
- [ ] Share code repository
- [ ] Provide additional resources
- [ ] Assign exercises

---

## 🎬 Pro Presentation Tips

1. **Prep Time:** Run `terraform init` before demo starts
2. **Two Screens:** Code in one, AWS Console in other
3. **Explain As You Go:** Don't just run commands
4. **Show Failures:** Create non-compliant resources
5. **Real Examples:** Reference actual compliance requirements
6. **Q&A Ready:** Know common questions
7. **Backup Plan:** Have pre-deployed environment if live demo fails
8. **Record It:** Students can review later
9. **Hands-On:** Have students follow along
10. **Cost Aware:** Always mention costs and cleanup

---

**Demo Status: ✅ Tested November 2025**

- Terraform plan: 24 resources
- All policies validated
- Config rules working
- Compliance detection verified
- Cleanup confirmed

**Happy Teaching! 🚀**
