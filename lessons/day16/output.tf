
output "users_names" {
  // get the user name 
  value = [for user in local.users : "${user.first_name} ${user.last_name}"]
}

// user password
output "user_password" {
  value = {
    for user, profile in aws_iam_user_login_profile.users :
  user => "password created -   user must reset on first login" }
  sensitive = true

}
