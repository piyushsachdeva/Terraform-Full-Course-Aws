#!/bin/bash
set -e

echo "🗑️  Destroying Image Processor Application..."

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed."
    exit 1
fi

cd "$PROJECT_DIR/terraform"

# Get bucket names before destroying
UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name 2>/dev/null || echo "")
PROCESSED_BUCKET=$(terraform output -raw processed_bucket_name 2>/dev/null || echo "")
FRONTEND_BUCKET=$(terraform output -raw frontend_bucket_name 2>/dev/null || echo "")

# Function to empty versioned S3 bucket
empty_versioned_bucket() {
    local bucket=$1
    echo "🗑️  Emptying bucket: $bucket (including all versions)..."
    
    # Delete all object versions
    aws s3api list-object-versions --bucket "$bucket" --output json | \
    jq -r '.Versions[]? | "\(.Key) \(.VersionId)"' | \
    while read key version; do
        if [ ! -z "$key" ]; then
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" 2>/dev/null || true
        fi
    done
    
    # Delete all delete markers
    aws s3api list-object-versions --bucket "$bucket" --output json | \
    jq -r '.DeleteMarkers[]? | "\(.Key) \(.VersionId)"' | \
    while read key version; do
        if [ ! -z "$key" ]; then
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" 2>/dev/null || true
        fi
    done
    
    echo "✓ Bucket $bucket emptied"
}

# Empty S3 buckets
if [ ! -z "$UPLOAD_BUCKET" ]; then
    empty_versioned_bucket "$UPLOAD_BUCKET"
fi

if [ ! -z "$PROCESSED_BUCKET" ]; then
    empty_versioned_bucket "$PROCESSED_BUCKET"
fi

if [ ! -z "$FRONTEND_BUCKET" ]; then
    empty_versioned_bucket "$FRONTEND_BUCKET"
fi

# Destroy Terraform resources
echo "🔥 Destroying Terraform resources..."
terraform destroy -auto-approve

echo "✅ All resources destroyed successfully!"
