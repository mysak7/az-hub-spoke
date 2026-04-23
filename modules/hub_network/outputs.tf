output "resource_group_name" {
  value       = azurerm_resource_group.hub.name
  description = "Name of the Hub resource group."
}

output "vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "Resource ID of the Hub VNet."
}

output "vnet_name" {
  value       = azurerm_virtual_network.hub.name
  description = "Name of the Hub VNet."
}

output "firewall_subnet_id" {
  value       = azurerm_subnet.firewall.id
  description = "ID of AzureFirewallSubnet."
}

output "bastion_subnet_id" {
  value       = azurerm_subnet.bastion.id
  description = "ID of AzureBastionSubnet."
}

output "shared_subnet_id" {
  value       = azurerm_subnet.shared.id
  description = "ID of the Shared Services subnet."
}

output "dns_subnet_id" {
  value       = azurerm_subnet.dns.id
  description = "ID of the DNS subnet."
}
