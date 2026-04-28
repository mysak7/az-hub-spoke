locals {
  storage_name = substr(
    "st${replace(var.prefix, "-", "")}${var.environment}${var.location_short}fl",
    0, 24
  )
}

# ── Log Analytics Workspace ───────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.prefix}-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ── Storage Account for NSG Flow Logs ────────────────────────────────────────

resource "azurerm_storage_account" "flow_logs" {
  name                     = local.storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# ── Network Watcher ───────────────────────────────────────────────────────────
# Azure auto-creates NetworkWatcher_<region> in NetworkWatcherRG when VNets are
# deployed. If that already exists, import it before applying:
#   terraform import module.monitoring.azurerm_network_watcher.this \
#     /subscriptions/<sub>/resourceGroups/NetworkWatcherRG/providers/\
#     Microsoft.Network/networkWatchers/NetworkWatcher_<region>

resource "azurerm_network_watcher" "this" {
  name                = "nw-${var.prefix}-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ── NSG Flow Logs with Traffic Analytics ─────────────────────────────────────

resource "azurerm_network_watcher_flow_log" "spoke" {
  for_each = var.spoke_nsg_ids

  name                      = "fl-${each.key}-${var.environment}"
  network_watcher_name      = azurerm_network_watcher.this.name
  resource_group_name       = var.resource_group_name
  network_security_group_id = each.value
  storage_account_id        = azurerm_storage_account.flow_logs.id
  enabled                   = true
  version                   = 2
  location                  = var.location
  tags                      = var.tags

  retention_policy {
    enabled = true
    days    = var.log_retention_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region      = var.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    interval_in_minutes   = 10
  }
}

# ── Diagnostic Settings: Azure Firewall → Log Analytics ──────────────────────

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "diag-firewall-to-law"
  target_resource_id         = var.firewall_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log { category = "AZFWNetworkRule" }
  enabled_log { category = "AZFWApplicationRule" }
  enabled_log { category = "AZFWNatRule" }
  enabled_log { category = "AZFWThreatIntel" }
  enabled_log { category = "AZFWIdpsSignature" }
  enabled_log { category = "AZFWDnsProxy" }

  enabled_metric {
    category = "AllMetrics"
  }
}

# ── Diagnostic Settings: Azure Bastion → Log Analytics ───────────────────────

resource "azurerm_monitor_diagnostic_setting" "bastion" {
  name                       = "diag-bastion-to-law"
  target_resource_id         = var.bastion_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log { category = "BastionAuditLogs" }
}

# ── Monitor Action Group ──────────────────────────────────────────────────────

resource "azurerm_monitor_action_group" "ops" {
  name                = "ag-${var.prefix}-ops-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "ops"
  tags                = var.tags

  email_receiver {
    name          = "ops-email"
    email_address = var.alert_email
  }
}

# ── Metric Alert: Firewall Health ─────────────────────────────────────────────

resource "azurerm_monitor_metric_alert" "firewall_health" {
  name                = "alert-afw-health-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Fires when Azure Firewall health drops below 90%."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

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

# ── Metric Alert: Firewall SNAT Port Exhaustion ───────────────────────────────

resource "azurerm_monitor_metric_alert" "firewall_snat" {
  name                = "alert-afw-snat-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.firewall_id]
  description         = "Fires when SNAT port utilization exceeds 80% — risk of connection failures."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

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

# ── Metric Alert: Bastion Active Sessions ────────────────────────────────────

resource "azurerm_monitor_metric_alert" "bastion_sessions" {
  name                = "alert-bastion-sessions-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [var.bastion_id]
  description         = "Fires when active Bastion sessions exceed 50 — capacity planning signal."
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

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
