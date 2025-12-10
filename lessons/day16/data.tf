data "aws_caller_identity" "account" {}

output "account_id" {
  value = data.aws_caller_identity.account.account_id
}


