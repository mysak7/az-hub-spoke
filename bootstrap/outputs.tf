output "resource_group_name" {
  value       = azurerm_resource_group.tfstate.name
  description = "Resource group containing the Terraform state storage account."
}

output "storage_account_name" {
  value       = azurerm_storage_account.tfstate.name
  description = "Storage account name — use this in the backend.tf `storage_account_name` field."
}

output "container_name" {
  value       = azurerm_storage_container.tfstate.name
  description = "Blob container name for Terraform state."
}

output "backend_config_snippet" {
  value       = <<-EOT
    # Paste this into environments/dev/backend.tf:
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.tfstate.name}"
        storage_account_name = "${azurerm_storage_account.tfstate.name}"
        container_name       = "${azurerm_storage_container.tfstate.name}"
        key                  = "dev.terraform.tfstate"
        use_azuread_auth     = true
      }
    }
  EOT
  description = "Ready-to-paste backend block."
}
