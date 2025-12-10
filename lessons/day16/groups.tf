// iam user groups - engineers
resource "aws_iam_group" "engineers" {
  name = "engineers"
}


// iam user groups - managers
resource "aws_iam_group" "managers" {
  name = "managers"
  path = "/groups/"
}


// education 
resource "aws_iam_group_membership" "education" {
  name  = "education"
  users = [for user in aws_iam_user.users : user.name if user.tags.Department == "Education"]
  group = aws_iam_group.engineers.name
}


// for managers  
resource "aws_iam_group_membership" "managers" {
  name  = "managers"
  users = [for user in aws_iam_user.users : user.name if contains(keys(user.tags), "JobTitle") && can(regex("Manager|CEO", user.tags.JobTitle))]
  group = aws_iam_group.managers.name
}


// for engineers 
resource "aws_iam_group_membership" "engineers" {
  name  = "engineers"
  users = [for user in aws_iam_user.users : user.name if user.tags.Department == "Engineers"]
  group = aws_iam_group.engineers.name
}
