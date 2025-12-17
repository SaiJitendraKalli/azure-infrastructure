output "public_subnet_name" {
  value = azurerm_subnet.databricks_public_subnet.name
}
output "private_subnet_name" {
  value = azurerm_subnet.databricks_private_subnet.name
}
output "vnet_id" {
  value = azurerm_virtual_network.virtual_network.id
}
output "network_security_group_id" {
  value = azurerm_network_security_group.default_nsg.id
}
output "shared_subnet_id" {
  value = azurerm_subnet.shared_subnet.id
}
output "public_subnet_network_security_group_association_id" {
  value = azurerm_subnet_network_security_group_association.databricks_public_nsg_association.id
}
output "private_subnet_network_security_group_association_id" {
  value = azurerm_subnet_network_security_group_association.databricks_private_nsg_association.id
}
