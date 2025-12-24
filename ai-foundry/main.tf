resource "azurerm_ai_foundry" "ai_foundry" {
  name                = "ai-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id
  key_vault_id        = var.key_vault_id
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_ai_services" "ai_services" {
  name                = "ai-services-${var.application_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "S0"
}

resource "azurerm_ai_foundry_project" "ai_foundry_project" {
  name               = "ai-foundry-${var.application_name}-project"
  description        = "Default AI Foundry Project"
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.ai_foundry.id
}
