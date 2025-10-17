# ==============================
# Terraform Backend Configuration
# ==============================

# Note: This is commented out by default
# Uncomment and configure when you're ready to use remote state

/*
terraform {
  backend "s3" {
    # S3 bucket name for storing state
    bucket = "my-terraform-state-bucket"
    
    # Path to state file within the bucket
    key = "day09/lifecycle-demo/terraform.tfstate"
    
    # AWS region where the bucket exists
    region = "us-east-1"
    
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"
    
    # Enable encryption at rest
    encrypt = true
    
    # Optional: Workspace-based state management
    # workspace_key_prefix = "workspaces"
  }
}
*/

# To use the backend:
# 1. Create an S3 bucket for state storage
# 2. Create a DynamoDB table with primary key "LockID" (String)
# 3. Uncomment the above configuration
# 4. Update bucket, key, region, and table name
# 5. Run: terraform init -reconfigure
