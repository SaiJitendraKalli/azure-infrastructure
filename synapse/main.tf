resource "azurerm_storage_data_lake_gen2_filesystem" "datalake_filesystem" {
  name               = "datalakefilesystem${var.application_name}"
  storage_account_id = var.storage_account_id
}


resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "synapseworkspace${var.application_name}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.storage_account_id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = var.sql_password_secret_id
  identity {
    type = "SystemAssigned"
  }
}
