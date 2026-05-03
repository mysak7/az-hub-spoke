locals {
  # 6-char suffix from subscription ID keeps App Service names globally unique
  name_suffix      = substr(replace(var.subscription_id, "-", ""), 0, 6)
  status_page_name = "app-status-${var.environment}-${var.location_short}-${local.name_suffix}"
  hr_app_name      = "app-hr-${var.environment}-${var.location_short}-${local.name_suffix}"
  finance_app_name = "app-finance-${var.environment}-${var.location_short}-${local.name_suffix}"
  admin_app_name   = "app-admin-${var.environment}-${var.location_short}-${local.name_suffix}"
}

# Dedicated subnet for App Service regional VNet integration
resource "azurerm_subnet" "webapps" {
  name                 = "snet-webapps"
  resource_group_name  = azurerm_resource_group.app.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.1.4.0/24"]

  delegation {
    name = "app-service"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_service_plan" "apps" {
  name                = "asp-${var.environment}-${var.location_short}-apps"
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "S1"
  tags                = local.tags
}

data "archive_file" "placeholder" {
  type        = "zip"
  source_dir  = "${path.root}/apps/placeholder"
  output_path = "${path.root}/apps/placeholder.zip"
}

data "archive_file" "status_page" {
  type        = "zip"
  source_dir  = "${path.root}/apps/status-page"
  output_path = "${path.root}/apps/status-page.zip"
}

resource "azurerm_linux_web_app" "hr" {
  name                      = local.hr_app_name
  resource_group_name       = azurerm_resource_group.app.name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.apps.id
  virtual_network_subnet_id = azurerm_subnet.webapps.id
  https_only                = true
  zip_deploy_file           = data.archive_file.placeholder.output_path

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "APP_TITLE"                      = "HR Portal"
    "APP_DESCRIPTION"                = "Human Resources management and employee records"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "AZURE_CLIENT_SECRET"            = azuread_application_password.hr_portal.value
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = azuread_application.hr_portal.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "AZURE_CLIENT_SECRET"
      allowed_groups             = [azuread_group.hr_users.object_id]
    }

    login {
      token_store_enabled = true
    }
  }

  tags = local.tags
}

resource "azurerm_linux_web_app" "finance" {
  name                      = local.finance_app_name
  resource_group_name       = azurerm_resource_group.app.name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.apps.id
  virtual_network_subnet_id = azurerm_subnet.webapps.id
  https_only                = true
  zip_deploy_file           = data.archive_file.placeholder.output_path

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "APP_TITLE"                      = "Finance Dashboard"
    "APP_DESCRIPTION"                = "Financial reporting, budgets and analytics"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "AZURE_CLIENT_SECRET"            = azuread_application_password.finance_dashboard.value
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = azuread_application.finance_dashboard.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "AZURE_CLIENT_SECRET"
      allowed_groups             = [azuread_group.finance_users.object_id]
    }

    login {
      token_store_enabled = true
    }
  }

  tags = local.tags
}

resource "azurerm_linux_web_app" "admin_portal" {
  name                      = local.admin_app_name
  resource_group_name       = azurerm_resource_group.app.name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.apps.id
  virtual_network_subnet_id = azurerm_subnet.webapps.id
  https_only                = true
  zip_deploy_file           = data.archive_file.placeholder.output_path

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "APP_TITLE"                      = "Admin Portal"
    "APP_DESCRIPTION"                = "Platform administration and configuration"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "AZURE_CLIENT_SECRET"            = azuread_application_password.admin_portal.value
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = azuread_application.admin_portal.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "AZURE_CLIENT_SECRET"
      allowed_groups             = [azuread_group.platform_admins.object_id]
    }

    login {
      token_store_enabled = true
    }
  }

  tags = local.tags
}

resource "azurerm_linux_web_app" "status_page" {
  name                = local.status_page_name
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.apps.id
  https_only          = true
  zip_deploy_file     = data.archive_file.status_page.output_path

  site_config {
    app_command_line = "gunicorn --bind=0.0.0.0 --timeout 600 app:app"
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "AZURE_CLIENT_ID"                = azuread_application.status_page.client_id
    "AZURE_CLIENT_SECRET"            = azuread_application_password.status_page.value
    "AZURE_TENANT_ID"                = data.azuread_client_config.current.tenant_id
    "GROUP_HR_ID"                    = azuread_group.hr_users.object_id
    "GROUP_FINANCE_ID"               = azuread_group.finance_users.object_id
    "GROUP_ADMINS_ID"                = azuread_group.platform_admins.object_id
    "APP_HR_URL"                     = "https://${local.hr_app_name}.azurewebsites.net"
    "APP_FINANCE_URL"                = "https://${local.finance_app_name}.azurewebsites.net"
    "APP_ADMIN_URL"                  = "https://${local.admin_app_name}.azurewebsites.net"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = azuread_application.status_page.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
      client_secret_setting_name = "AZURE_CLIENT_SECRET"
    }

    login {
      token_store_enabled = true
    }
  }

  tags = local.tags
}
