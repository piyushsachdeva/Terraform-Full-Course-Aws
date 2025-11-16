# 🎬 Demo Guide: Manual Deployment Steps

This guide walks you through the deployment process step-by-step, explaining what happens in `deploy.sh` so you can demonstrate it manually and help others understand the workflow.

## 📋 What You'll Learn

By following this guide, you'll understand:
- How to build Lambda layers for Python dependencies
- How to initialize and configure Terraform
- How to plan and apply infrastructure changes
- How to verify your deployment and test it

---

## 🚀 Prerequisites Check

Before starting, verify that required tools are installed:

### Step 1: Check AWS CLI
```bash
aws --version
```
**Expected Output:** `aws-cli/2.x.x` or higher

If not installed, install from: https://aws.amazon.com/cli/

### Step 2: Check Terraform
```bash
terraform --version
```
**Expected Output:** `Terraform v1.x.x` or higher

If not installed, install from: https://www.terraform.io/downloads

### Step 3: Verify AWS Credentials
```bash
aws sts get-caller-identity
```
**Expected Output:** Your AWS account details (Account ID, User ARN, etc.)

**💡 Explanation:** This ensures you have valid AWS credentials configured and can interact with AWS services.

---

## 📦 Phase 1: Build Lambda Layer

Lambda layers allow us to package dependencies separately from our function code. This is useful for large libraries like Pillow (image processing library).

### Step 4: Navigate to the Project Directory
```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day18
```

### Step 5: Understand the Requirements
```bash
cat lambda/requirements.txt
```
**Expected Output:** 
```
Pillow==10.4.0
boto3
```

**💡 Explanation:** 
- **Pillow**: Python Imaging Library for image processing (resize, compress, convert formats)
- **boto3**: AWS SDK for Python (usually pre-installed in Lambda, but listed for completeness)

### Step 6: Build the Layer Manually

Create a temporary directory structure:
```bash
mkdir -p /tmp/lambda-layer/python/lib/python3.12/site-packages
```

**💡 Explanation:** Lambda expects layers in a specific directory structure: `python/lib/pythonX.X/site-packages/`

### Step 7: Install Pillow into the Layer
```bash
pip install -t /tmp/lambda-layer/python/lib/python3.12/site-packages Pillow==10.4.0
```

**💡 Explanation:** 
- `-t` flag specifies the target directory
- We install to this specific path so Lambda can find it at runtime

**Expected Output:** Download and installation messages from pip

### Step 8: Create the Layer ZIP File
```bash
cd /tmp/lambda-layer
zip -r pillow_layer.zip python/
```

**💡 Explanation:** Lambda layers must be uploaded as ZIP files. The structure inside the ZIP is important - Lambda will look for `python/lib/pythonX.X/site-packages/` inside the ZIP.

### Step 9: Move Layer to Terraform Directory
```bash
mv pillow_layer.zip /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day18/terraform/
```

**💡 Explanation:** Terraform will reference this ZIP file when creating the Lambda layer resource.

### Step 10: Verify the Layer
```bash
ls -lh /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day18/terraform/pillow_layer.zip
```

**Expected Output:** A file around 3-4 MB in size

### Step 11: Cleanup
```bash
rm -rf /tmp/lambda-layer
```

---

## 🔧 Phase 2: Initialize Terraform

Terraform needs to download provider plugins and prepare the backend.

### Step 12: Navigate to Terraform Directory
```bash
cd /home/baivab/repos/Terraform-Full-Course-Aws/lessons/day18/terraform
```

### Step 13: Review Terraform Configuration Files

#### View the Provider Configuration:
```bash
cat provider.tf
```

**💡 Explanation:** This file specifies:
- Which cloud provider (AWS)
- The AWS region to deploy to
- Required provider versions

#### View the Variables:
```bash
cat variables.tf
```

**💡 Explanation:** Variables make the configuration reusable and customizable.

#### View the Main Configuration:
```bash
cat main.tf
```

**💡 Explanation:** This is where all AWS resources are defined:
- S3 buckets (for uploads and processed images)
- Lambda function and layer
- IAM roles and policies
- CloudWatch log groups

### Step 14: Initialize Terraform
```bash
terraform init
```

**💡 Explanation:** This command:
- Downloads AWS provider plugins
- Sets up the backend for state storage
- Prepares the working directory

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

### Step 15: Verify Initialization
```bash
ls -la .terraform/
```

**💡 Explanation:** The `.terraform/` directory contains downloaded provider plugins.

---

## 📋 Phase 3: Plan the Deployment

Planning shows you what Terraform will create, modify, or destroy WITHOUT actually making changes.

### Step 16: Create a Terraform Plan
```bash
terraform plan -out=tfplan
```

**💡 Explanation:** 
- `plan` analyzes your configuration and compares it to the current state
- `-out=tfplan` saves the plan to a file for later use
- This is a safety feature - review before applying!

**Expected Output:**
```
Terraform will perform the following actions:

  # aws_s3_bucket.upload will be created
  + resource "aws_s3_bucket" "upload" {
      + bucket        = "image-upload-xxxxx"
      ...
    }

  # aws_lambda_function.image_processor will be created
  ...

Plan: 15 to add, 0 to change, 0 to destroy.
```

### Step 17: Review the Plan Output
Look for:
- **Green (+)**: Resources to be created
- **Yellow (~)**: Resources to be modified
- **Red (-)**: Resources to be destroyed
- **Summary**: Total count of changes

**💡 Key Questions to Ask:**
1. Are you creating the expected number of resources? (should be ~15-20)
2. Do the resource names make sense?
3. Are there any unexpected deletions or modifications?

### Step 18: Inspect the Saved Plan (Optional)
```bash
terraform show tfplan
```

**💡 Explanation:** This shows the detailed plan in a human-readable format.

---

## 🚀 Phase 4: Apply the Deployment

Now we'll actually create the infrastructure!

### Step 19: Apply the Terraform Plan
```bash
terraform apply tfplan
```

**💡 Explanation:** 
- This executes the saved plan
- Since we're using a saved plan file, no confirmation is needed
- Terraform will create all resources in dependency order

**Expected Output:**
```
aws_iam_role.lambda: Creating...
aws_s3_bucket.upload: Creating...
aws_s3_bucket.processed: Creating...
...
aws_lambda_function.image_processor: Creation complete after 15s

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
lambda_function_name = "image-processor-xxxxx"
upload_bucket_name = "image-upload-xxxxx"
processed_bucket_name = "image-processed-xxxxx"
region = "us-east-1"
```

### Step 20: Watch the Progress

**💡 Things Happening in Order:**
1. **IAM Role** created first (Lambda needs permissions)
2. **S3 Buckets** created (for storing images)
3. **Lambda Layer** uploaded (contains Pillow library)
4. **Lambda Function** created (with the layer attached)
5. **S3 Event Notifications** configured (trigger Lambda on upload)
6. **CloudWatch Log Group** created (for function logs)

This usually takes **2-5 minutes**.

---

## 📊 Phase 5: Verify and Test

### Step 21: Get Deployment Outputs
```bash
terraform output
```

**Expected Output:**
```
lambda_function_name = "image-processor-20231116abc123"
processed_bucket_name = "image-processed-20231116abc123"
region = "us-east-1"
upload_bucket_name = "image-upload-20231116abc123"
```

**💡 Explanation:** Terraform outputs are useful values from your deployment that you'll need for testing.

### Step 22: Save Output Values to Variables
```bash
UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name)
PROCESSED_BUCKET=$(terraform output -raw processed_bucket_name)
LAMBDA_FUNCTION=$(terraform output -raw lambda_function_name)
REGION=$(terraform output -raw region)
```

**💡 Explanation:** The `-raw` flag gives us the value without quotes, perfect for scripting.

### Step 23: Display the Information
```bash
echo "Upload Bucket: s3://${UPLOAD_BUCKET}"
echo "Processed Bucket: s3://${PROCESSED_BUCKET}"
echo "Lambda Function: ${LAMBDA_FUNCTION}"
echo "Region: ${REGION}"
```

---

## 🧪 Phase 6: Test the Application

### Step 24: Prepare a Test Image

If you don't have a test image, create a simple one:
```bash
# Install ImageMagick if needed (optional)
# For Ubuntu/Debian: sudo apt-get install imagemagick

# Create a simple test image using ImageMagick
convert -size 800x600 xc:blue -fill white -pointsize 72 -gravity center -annotate +0+0 "TEST" test-image.jpg
```

Or download one:
```bash
curl -o test-image.jpg https://picsum.photos/800/600
```

### Step 25: Upload Image to S3
```bash
aws s3 cp test-image.jpg s3://${UPLOAD_BUCKET}/
```

**💡 Explanation:** This uploads the image to the upload bucket, which triggers the Lambda function automatically.

**Expected Output:**
```
upload: ./test-image.jpg to s3://image-upload-xxxxx/test-image.jpg
```

### Step 26: Watch Lambda Execution in Real-time
```bash
aws logs tail /aws/lambda/${LAMBDA_FUNCTION} --follow
```

**💡 Explanation:** This streams the Lambda function logs in real-time. You should see:
- Event received
- Image being processed
- Different format variants being created
- Upload confirmations

**Expected Log Output:**
```
2024-11-16T10:30:45.123Z START RequestId: abc-123-def-456
2024-11-16T10:30:45.456Z INFO Processing image: test-image.jpg
2024-11-16T10:30:46.789Z INFO Creating JPEG variant (quality: 85)
2024-11-16T10:30:47.012Z INFO Creating PNG variant
2024-11-16T10:30:47.345Z INFO Creating WEBP variant (quality: 85)
2024-11-16T10:30:47.678Z INFO Uploaded: processed/test-image_q85.jpg
2024-11-16T10:30:47.890Z END RequestId: abc-123-def-456
```

Press `Ctrl+C` to stop following logs.

### Step 27: List Processed Images
```bash
aws s3 ls s3://${PROCESSED_BUCKET}/processed/ --recursive --human-readable
```

**Expected Output:**
```
2024-11-16 10:30:47   45.2 KiB processed/test-image_q85.jpg
2024-11-16 10:30:47  123.4 KiB processed/test-image.png
2024-11-16 10:30:47   38.9 KiB processed/test-image_q85.webp
```

**💡 Explanation:** The Lambda function created multiple variants:
- JPEG with 85% quality
- PNG format
- WebP format (modern, efficient)

### Step 28: Download and Compare Results
```bash
# Create a results directory
mkdir -p test-results

# Download original
aws s3 cp s3://${UPLOAD_BUCKET}/test-image.jpg test-results/original.jpg

# Download processed versions
aws s3 cp s3://${PROCESSED_BUCKET}/processed/ test-results/ --recursive

# Check file sizes
ls -lh test-results/
```

**💡 Explanation:** Compare the file sizes. The processed images should be optimized (usually smaller) while maintaining good quality.

### Step 29: View CloudWatch Metrics
```bash
# Get function invocation count
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=${LAMBDA_FUNCTION} \
  --start-time $(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum \
  --region ${REGION}
```

**💡 Explanation:** This shows how many times your Lambda function was invoked in the last 10 minutes.

---

## 🎯 Phase 7: Understanding What Was Deployed

### Step 30: Review the Complete Architecture

Let's understand what we've built:

#### 1. **S3 Upload Bucket**
```bash
aws s3 ls s3://${UPLOAD_BUCKET}
```
- Purpose: Receives original images from users
- Trigger: Configured to invoke Lambda on object creation

#### 2. **S3 Processed Bucket**
```bash
aws s3 ls s3://${PROCESSED_BUCKET}
```
- Purpose: Stores processed/optimized images
- Content: Multiple variants (JPEG, PNG, WebP)

#### 3. **Lambda Function**
```bash
aws lambda get-function --function-name ${LAMBDA_FUNCTION}
```
- Runtime: Python 3.12
- Handler: `lambda_function.lambda_handler`
- Layer: Includes Pillow for image processing
- Memory: Check the configuration
- Timeout: Check the configuration

#### 4. **Lambda Layer**
```bash
aws lambda list-layers
```
- Contains: Pillow library
- Version: Check the latest version

#### 5. **IAM Role**
```bash
aws iam list-attached-role-policies --role-name ${LAMBDA_FUNCTION}-role
```
- Permissions: S3 read/write, CloudWatch Logs

#### 6. **CloudWatch Log Group**
```bash
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/${LAMBDA_FUNCTION}
```
- Purpose: Stores Lambda execution logs
- Retention: Check retention period

---

## 🧹 Phase 8: Cleanup (When Done)

### Step 31: Empty S3 Buckets First
```bash
# Empty upload bucket
aws s3 rm s3://${UPLOAD_BUCKET} --recursive

# Empty processed bucket
aws s3 rm s3://${PROCESSED_BUCKET} --recursive
```

**💡 Explanation:** S3 buckets must be empty before Terraform can delete them.

### Step 32: Destroy Infrastructure
```bash
terraform destroy
```

Type `yes` when prompted.

**💡 Explanation:** This removes all resources created by Terraform, in reverse dependency order.

---

## 📚 Summary: What Each Step Does

| Phase | What Happens | Why It Matters |
|-------|--------------|----------------|
| **1. Build Layer** | Package Pillow library into a Lambda layer | Lambda functions can't install packages at runtime; layers provide dependencies |
| **2. Initialize** | Download Terraform providers and prepare workspace | Terraform needs provider plugins to interact with AWS APIs |
| **3. Plan** | Preview infrastructure changes | Safety check - see what will be created before it happens |
| **4. Apply** | Create AWS resources | Actually provisions your infrastructure in AWS |
| **5. Verify** | Get outputs and check resources | Ensure everything deployed correctly |
| **6. Test** | Upload image and check processing | Validate the application works end-to-end |
| **7. Understand** | Explore created resources | Learn how all pieces connect together |
| **8. Cleanup** | Remove all resources | Avoid AWS charges for unused resources |

---

## 🎓 Teaching Tips

When demonstrating this to others:

1. **Start with the Big Picture**: Show the architecture diagram first
2. **Explain WHY before HOW**: Explain why we need each component before showing the commands
3. **Use Real Examples**: Actually upload an image and show the results
4. **Show the Logs**: Live Lambda logs are impressive and educational
5. **Compare Files**: Download and compare original vs. processed image sizes
6. **Cost Awareness**: Explain AWS Free Tier and potential costs
7. **Troubleshooting**: Show common errors and how to fix them

---

## ❓ Common Questions & Answers

**Q: Why do we need a Lambda layer?**
A: Pillow is a large library (~3MB). Layers allow us to reuse it across multiple functions and keep deployment packages small.

**Q: Why not just run `deploy.sh`?**
A: Understanding each step helps with troubleshooting and customization. Automation is great, but knowledge is better!

**Q: How much does this cost?**
A: Within AWS Free Tier:
- Lambda: 1M requests/month free
- S3: 5GB storage, 20K GET requests, 2K PUT requests free
- CloudWatch: 5GB logs free

**Q: Can I use this in production?**
A: This is a learning demo. For production, add:
- Error handling
- DLQ (Dead Letter Queue)
- API Gateway for web interface
- CloudFront for CDN
- Monitoring and alerts

**Q: What if the Lambda fails?**
A: Check CloudWatch Logs:
```bash
aws logs tail /aws/lambda/${LAMBDA_FUNCTION} --follow
```

---

## 🔗 Next Steps

After mastering this demo:

1. **Customize the Lambda function** to add watermarks
2. **Add API Gateway** for direct uploads via API
3. **Create a web frontend** for a complete application
4. **Add image metadata extraction** (EXIF data)
5. **Implement caching** with CloudFront
6. **Add SNS notifications** when processing completes

---

## 📞 Getting Help

If something doesn't work:

1. Check CloudWatch Logs for Lambda errors
2. Verify AWS credentials: `aws sts get-caller-identity`
3. Check Terraform state: `terraform show`
4. Review IAM permissions
5. Ensure buckets are in the same region as Lambda

Happy Learning! 🚀
