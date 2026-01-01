variable "application_name" {
  type = string
}
variable "location" {
  type = string
}
variable "environment" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sql_password_secret_value" {
  type      = string
  sensitive = true
}

variable "storage_account_id" {
  type = string
}
