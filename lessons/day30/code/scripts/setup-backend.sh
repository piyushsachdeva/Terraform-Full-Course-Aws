#!/bin/bash
# Script to create S3 bucket and DynamoDB table for Terraform state management
# Run this once before using the Terraform workflows

set -e

# Configuration
BUCKET_NAME="${1:-terraform-state-$(date +%s)}"
AWS_REGION="${2:-us-east-1}"

echo "=========================================="
echo "Terraform Backend Setup (S3 Native Locking)"
echo "=========================================="
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $AWS_REGION"
echo "Locking: S3 native (Terraform 1.10.0+)"
echo "========================================="

# Create S3 bucket
echo "Creating S3 bucket..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  $(if [ "$AWS_REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=$AWS_REGION"; fi)

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo ""
echo "=========================================="
echo "✅ Backend setup complete!"
echo "=========================================="
echo ""
echo "Add this secret to GitHub:"
echo "Secret Name: TERRAFORM_STATE_BUCKET"
echo "Secret Value: $BUCKET_NAME"
echo ""
echo "Update backend config files:"
echo "  - backend-dev.hcl"
echo "  - backend-prod.hcl"
echo ""
echo "Replace 'TERRAFORM_STATE_BUCKET' with: $BUCKET_NAME"
echo "=========================================="
