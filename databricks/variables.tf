variable "application_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "workspace_type" {
  type    = string
  default = "Serverless"
  validation {
    condition     = contains(["Serverless", "Hybrid"], var.workspace_type)
    error_message = "workspace_type must be 'Serverless' or 'Hybrid'."
  }
}
variable "customer_managed_key_enabled" {
  type    = bool
  default = false
}
variable "managed_services_cmk_key_vault_key_id" {
  type    = string
  default = null
}
variable "managed_disk_cmk_key_vault_key_id" {
  type    = string
  default = null
}
variable "vnet_id" {
  type    = string
  default = null
}
variable "private_subnet_name" {
  type    = string
  default = null
}
variable "public_subnet_name" {
  type    = string
  default = null
}

variable "public_subnet_network_security_group_association_id" {
  type    = string
  default = null
}

variable "private_subnet_network_security_group_association_id" {
  type    = string
  default = null
}

variable "key_vault_id" {
  type    = string
  default = null
}
