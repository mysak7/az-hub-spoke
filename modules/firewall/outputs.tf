output "firewall_id" {
  value       = azurerm_firewall.this.id
  description = "Resource ID of the Azure Firewall."
}

output "firewall_private_ip" {
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
  description = "Private IP address of the Azure Firewall — used as the next-hop in spoke UDRs."
}

output "firewall_public_ip" {
  value       = azurerm_public_ip.firewall.ip_address
  description = "Public IP address of the Azure Firewall."
}

output "firewall_policy_id" {
  value       = azurerm_firewall_policy.this.id
  description = "Resource ID of the Firewall Policy."
}
