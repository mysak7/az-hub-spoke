output "hub_to_spoke_peering_id" {
  value       = azurerm_virtual_network_peering.hub_to_spoke.id
  description = "Resource ID of the hub-to-spoke VNet peering."
}

output "spoke_to_hub_peering_id" {
  value       = azurerm_virtual_network_peering.spoke_to_hub.id
  description = "Resource ID of the spoke-to-hub VNet peering."
}
