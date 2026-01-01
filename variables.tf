variable "application_name" {
  default = "data-maester"
  type    = string
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "clients" {
  type = list(string)

}
