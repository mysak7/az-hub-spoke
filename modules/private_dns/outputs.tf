output "dns_zone_ids" {
  value       = { for zone_name, zone in azurerm_private_dns_zone.this : zone_name => zone.id }
  description = "Map of DNS zone name → resource ID."
}

output "dns_zone_names" {
  value       = keys(azurerm_private_dns_zone.this)
  description = "List of created Private DNS zone names."
}
