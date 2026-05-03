output "hub_vnet_id" {
  description = "Resource ID of the Hub VNet."
  value       = azurerm_virtual_network.hub.id
}

output "firewall_private_ip" {
  description = "Private IP of the Azure Firewall."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Public IP of the Azure Firewall."
  value       = azurerm_public_ip.firewall.ip_address
}

output "bastion_public_ip" {
  description = "Public IP of Azure Bastion."
  value       = azurerm_public_ip.bastion.ip_address
}

output "app_vnet_id" {
  description = "Resource ID of the App Spoke VNet."
  value       = azurerm_virtual_network.app.id
}

output "mgmt_vnet_id" {
  description = "Resource ID of the Management Spoke VNet."
  value       = azurerm_virtual_network.mgmt.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "status_page_url" {
  description = "Public URL of the Entra ID-protected access status page."
  value       = "https://${azurerm_linux_web_app.status_page.default_hostname}"
}

output "hr_app_url" {
  description = "URL of the HR Portal (App Spoke, VNet integrated)."
  value       = "https://${azurerm_linux_web_app.hr.default_hostname}"
}

output "finance_app_url" {
  description = "URL of the Finance Dashboard (App Spoke, VNet integrated)."
  value       = "https://${azurerm_linux_web_app.finance.default_hostname}"
}

output "admin_app_url" {
  description = "URL of the Admin Portal (App Spoke, VNet integrated)."
  value       = "https://${azurerm_linux_web_app.admin_portal.default_hostname}"
}

output "entra_groups" {
  description = "Entra ID group object IDs for manual user assignment."
  value = {
    hr_users        = azuread_group.hr_users.object_id
    finance_users   = azuread_group.finance_users.object_id
    platform_admins = azuread_group.platform_admins.object_id
  }
}
