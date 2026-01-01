

resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-${var.application_name}-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "EP1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                          = "func-${var.application_name}-${var.location}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.app_service_plan.id
  storage_account_name          = azurerm_storage_account.function_storage.name
  storage_uses_managed_identity = true
  app_settings                  = local.app_settings

  site_config {
    application_stack {
      python_version = "3.13"
    }
  }
  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "Return401"
    login {
      token_store_enabled = true
    }
    active_directory_v2 {
      client_id            = data.azurerm_client_config.current.client_id
      tenant_auth_endpoint = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
      allowed_audiences    = [for client_id in var.clients : "api://${client_id}"]
      allowed_applications = var.clients
    }
  }
  identity {
    type = "SystemAssigned"
  }

}
