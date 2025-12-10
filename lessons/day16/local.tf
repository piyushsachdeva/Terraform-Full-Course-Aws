locals {

  // csvdecode - converts all content of csv file into a list of maps
  users = csvdecode(file("users.csv"))
}
