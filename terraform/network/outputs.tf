output "hub_vnet_id" {
  description = "Resource ID of the Hub VNet."
  value       = azurerm_virtual_network.hub.id
}

output "app_vnet_id" {
  description = "Resource ID of the App Spoke VNet."
  value       = azurerm_virtual_network.app.id
}

output "mgmt_vnet_id" {
  description = "Resource ID of the Management Spoke VNet."
  value       = azurerm_virtual_network.mgmt.id
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

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "webapps_subnet_id" {
  description = "Resource ID of the App Service VNet integration subnet."
  value       = azurerm_subnet.webapps.id
}
