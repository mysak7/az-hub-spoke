output "hub_vnet_id" {
  value       = module.hub_network.vnet_id
  description = "Resource ID of the Hub VNet."
}

output "firewall_private_ip" {
  value       = module.firewall.firewall_private_ip
  description = "Private IP of the Azure Firewall — next-hop for spoke UDRs."
}

output "firewall_public_ip" {
  value       = module.firewall.firewall_public_ip
  description = "Public IP of the Azure Firewall."
}

output "bastion_public_ip" {
  value       = module.bastion.bastion_public_ip
  description = "Public IP of Azure Bastion (entry point for spoke VM access)."
}

output "app_spoke_vnet_id" {
  value       = module.app_spoke.vnet_id
  description = "Resource ID of the App Spoke VNet."
}

output "app_spoke_subnet_ids" {
  value       = module.app_spoke.subnet_ids
  description = "Map of logical name → subnet ID for the App Spoke."
}

output "mgmt_spoke_vnet_id" {
  value       = module.mgmt_spoke.vnet_id
  description = "Resource ID of the Management Spoke VNet."
}

output "private_dns_zone_ids" {
  value       = module.private_dns.dns_zone_ids
  description = "Map of Private DNS zone name → resource ID."
}
