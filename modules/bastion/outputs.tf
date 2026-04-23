output "bastion_id" {
  value       = azurerm_bastion_host.this.id
  description = "Resource ID of the Azure Bastion host."
}

output "bastion_public_ip" {
  value       = azurerm_public_ip.bastion.ip_address
  description = "Public IP address of the Azure Bastion host."
}
