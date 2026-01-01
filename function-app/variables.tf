variable "application_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}


variable "clients" {
  description = "List of client IDs for allowed audiences"
  type        = list(string)
  default     = []
}
variable "service_principal_name" {
  type    = string
  default = "terraform-cli"
}
variable "environment" {
  type = string
}
