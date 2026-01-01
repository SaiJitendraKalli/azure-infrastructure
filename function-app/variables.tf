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