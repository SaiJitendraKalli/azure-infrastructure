resource "azurerm_storage_account" "function_storage" {
  name                     = "st${var.application_name}${replace(var.location, "-", "")}func"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.function_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.function_app.identity[0].principal_id
}
