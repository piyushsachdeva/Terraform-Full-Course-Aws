terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-day08" # Can be passed via `-backend-config="bucket=<bucket name>"` in the `init` command
    key    = "dev/terraform.tfstate"           # Can be passed via `-backend-config="key=<state file path>"` in the `init` command
    region = "ca-central-1"                    # Can be passed via `-backend-config="region=<region>"` in the `init` command

    # Optional: DynamoDB table for state locking
    # dynamodb_table = "terraform-state-lock"  # Can be passed via `-backend-config="dynamodb_table=<table name>"` in the `init` command
    # encrypt        = true
  }
}
