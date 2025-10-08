#!/bin/bash

BUCKET_NAME="terraform-state-$(date +%s)"
REGION="us-east-1"

# Create S3 bucket for state storage
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable versioning on the bucket (REQUIRED for S3 native state locking)
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "======================================"
echo "S3 Backend Setup Complete!"
echo "======================================"
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo "Versioning: Enabled (required for state locking)"
echo "Encryption: Enabled (AES256)"
echo ""
echo "State Locking Method: S3 Native State Locking"
echo "  - Uses S3 Conditional Writes (If-None-Match header)"
echo "  - Creates temporary .tflock files in S3"
echo "  - No DynamoDB required (previously used)"
echo "  - Available in Terraform 1.10+ (stable in 1.11+)"
echo ""
echo "======================================"
echo "Update your backend.tf with:"
echo "======================================"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket       = \"$BUCKET_NAME\""
echo "    key          = \"dev/terraform.tfstate\""
echo "    region       = \"$REGION\""
echo "    use_lockfile = true"
echo "    encrypt      = true"
echo "  }"
echo "}"
echo ""
echo "Then run: terraform init"