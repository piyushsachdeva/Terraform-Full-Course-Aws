#!/bin/bash

BUCKET_NAME="terraform-state-$(date +%s)"
DYNAMODB_TABLE="terraform-state-lock"
REGION="us-east-1"

# Create S3 bucket for state storage
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable versioning on the bucket
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

# uss use_lockfile= "true" in backend.tf for state locking
#Terraform uses S3's PutObject + If-None-Match headers to simulate locking via .tflock files previsouly it was achived through DynamoDB