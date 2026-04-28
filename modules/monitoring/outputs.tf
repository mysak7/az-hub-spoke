output "workspace_id" {
  value       = azurerm_log_analytics_workspace.this.workspace_id
  description = "Log Analytics workspace GUID."
}

output "workspace_resource_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Resource ID of the Log Analytics workspace."
}

output "workspace_name" {
  value       = azurerm_log_analytics_workspace.this.name
  description = "Name of the Log Analytics workspace."
}

output "storage_account_id" {
  value       = azurerm_storage_account.flow_logs.id
  description = "Resource ID of the flow log storage account."
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.ops.id
  description = "Resource ID of the ops action group."
}
