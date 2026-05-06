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

output "frontdoor_url" {
  description = "Azure Front Door endpoint URL — entry point chráněný WAF."
  value       = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
}

output "entra_groups" {
  description = "Entra ID group object IDs for manual user assignment."
  value = {
    hr_users        = azuread_group.hr_users.object_id
    finance_users   = azuread_group.finance_users.object_id
    platform_admins = azuread_group.platform_admins.object_id
  }
}
