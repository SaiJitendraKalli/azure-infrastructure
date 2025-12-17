resource "azurerm_synapse_role_assignment" "synapse_admin" {
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
