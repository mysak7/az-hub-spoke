output "resource_group_name" {
  value       = azurerm_resource_group.spoke.name
  description = "Name of the spoke resource group."
}

output "vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "Resource ID of the spoke VNet."
}

output "vnet_name" {
  value       = azurerm_virtual_network.spoke.name
  description = "Name of the spoke VNet."
}

output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.this : k => s.id }
  description = "Map of logical subnet name → subnet resource ID."
}

output "route_table_id" {
  value       = azurerm_route_table.spoke.id
  description = "Resource ID of the spoke route table."
}
