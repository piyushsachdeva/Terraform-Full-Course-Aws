variable "name_prefix" {
  description = "Workspace-specific prefix for the bucket name."
  type        = string
}

variable "environment" {
  description = "Workspace name used for bucket tags."
  type        = string
}
