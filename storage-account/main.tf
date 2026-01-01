resource "azurerm_storage_account" "storage_account" {
  name                     = "sadatamaes${var.location}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}
