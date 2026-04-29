locals {
  dns_zones = toset([
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ])
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.dns_zones
  name                = each.key
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-${var.environment}-${var.location_short}-hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "app" {
  for_each = azurerm_private_dns_zone.this

  name                  = "link-${var.environment}-${var.location_short}-app"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.app.id
  registration_enabled  = false
  tags                  = local.tags
}
