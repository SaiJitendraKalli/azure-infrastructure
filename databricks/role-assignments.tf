
resource "azurerm_role_assignment" "disk_encryption_set_access" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_databricks_workspace.databricks_workspace.managed_disk_identity[0].principal_id
}
