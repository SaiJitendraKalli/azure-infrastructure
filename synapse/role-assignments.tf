
resource "azurerm_role_assignment" "synapse_contributor" {
  scope                = azurerm_synapse_workspace.synapse_workspace.id
  role_definition_name = "Synapse Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on           = [azurerm_synapse_firewall_rule.allow_azure_services]

}

resource "azurerm_role_assignment" "user_role" {
  scope                = azurerm_synapse_workspace.synapse_workspace.id
  role_definition_name = "Synapse Administrator"
  principal_id         = "5aa1aa7a-08a6-4e98-b77d-295f6900fd8f"
  depends_on           = [azurerm_synapse_firewall_rule.allow_azure_services]

}
