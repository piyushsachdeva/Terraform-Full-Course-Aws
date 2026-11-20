terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    key                  = "day30/terraform.tfstate"
    workspace_key_prefix = "workspaces"
    region               = "us-east-1"
    encrypt              = true
    use_lockfile         = true
  }
}
