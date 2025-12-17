resource "azurerm_storage_data_lake_gen2_filesystem" "datalake_filesystem" {
  name               = "datalakefilesystem${var.application_name}"
  storage_account_id = var.storage_account_id
}

resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "synapseworkspace-${var.application_name}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.datalake_filesystem.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = var.sql_password_secret_id
  identity {
    type = "SystemAssigned"
  }
  managed_virtual_network_enabled = false
  managed_resource_group_name     = false
  public_network_access_enabled   = true
}

resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name                 = "allowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}
