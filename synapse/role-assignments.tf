resource "azurerm_synapse_role_assignment" "synapse_admin" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Administrator"
  principal_id         = "5aa1aa7a-08a6-4e98-b77d-295f6900fd8f"
  depends_on           = [azurerm_synapse_workspace.synapse_workspace, azurerm_synapse_firewall_rule.allow_azure_services]
}
