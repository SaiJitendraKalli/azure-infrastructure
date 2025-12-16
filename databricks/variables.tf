variable "application_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "managed_services_cmk_key_vault_key_id" {
  type = string
}
variable "managed_disk_cmk_key_vault_key_id" {
  type = string
}
variable "vnet_id" {
  type = string
}
variable "private_subnet_name" {
  type = string
}
variable "public_subnet_name" {
  type = string
}

variable "public_subnet_network_security_group_association_id" {
  type = string
}

variable "private_subnet_network_security_group_association_id" {
  type = string
}
