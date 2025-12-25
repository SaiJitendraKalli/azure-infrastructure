
resource "azurerm_role_assignment" "disk_encryption_set_access" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_databricks_workspace.databricks_workspace.disk_encryption_set_id
}
