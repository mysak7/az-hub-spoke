locals {
  flow_logs_sa_name = substr("st${var.environment}${var.location_short}fl", 0, 24)
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_storage_account" "flow_logs" {
  name                     = local.flow_logs_sa_name
  resource_group_name      = azurerm_resource_group.network.name
  location                 = azurerm_resource_group.network.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

resource "azurerm_network_watcher" "this" {
  name                = "nw-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

resource "azurerm_network_watcher_flow_log" "app" {
  name                 = "fl-app-${var.environment}"
  network_watcher_name = azurerm_network_watcher.this.name
  resource_group_name  = azurerm_resource_group.network.name
  target_resource_id   = azurerm_virtual_network.app.id
  storage_account_id   = azurerm_storage_account.flow_logs.id
  enabled              = true
  location             = var.location
  tags                 = local.tags

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region      = var.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_network_watcher_flow_log" "mgmt" {
  name                 = "fl-mgmt-${var.environment}"
  network_watcher_name = azurerm_network_watcher.this.name
  resource_group_name  = azurerm_resource_group.network.name
  target_resource_id   = azurerm_virtual_network.mgmt.id
  storage_account_id   = azurerm_storage_account.flow_logs.id
  enabled              = true
  location             = var.location
  tags                 = local.tags

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region      = var.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "diag-firewall-to-law"
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log { category = "AZFWNetworkRule" }
  enabled_log { category = "AZFWNatRule" }
}

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  name                       = "diag-bastion-to-law"
  target_resource_id         = azurerm_bastion_host.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log { category = "BastionAuditLogs" }
}

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-${var.environment}-ops"
  resource_group_name = azurerm_resource_group.network.name
  short_name          = "ops"
  tags                = local.tags

  email_receiver {
    name          = "ops-email"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "firewall_health" {
  name                = "alert-afw-health-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  scopes              = [azurerm_firewall.this.id]
  description         = "Fires when Azure Firewall health drops below 90%."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "FirewallHealth"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

resource "azurerm_monitor_metric_alert" "firewall_snat" {
  name                = "alert-afw-snat-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  scopes              = [azurerm_firewall.this.id]
  description         = "Fires when SNAT port utilization exceeds 80%."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Network/azureFirewalls"
    metric_name      = "SNATPortUtilization"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}

resource "azurerm_monitor_metric_alert" "bastion_sessions" {
  name                = "alert-bastion-sessions-${var.environment}"
  resource_group_name = azurerm_resource_group.network.name
  scopes              = [azurerm_bastion_host.this.id]
  description         = "Fires when active Bastion sessions exceed 50."
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.Network/bastionHosts"
    metric_name      = "sessions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops.id
  }
}
