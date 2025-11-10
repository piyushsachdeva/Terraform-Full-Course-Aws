terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-piyushsachdeva"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
