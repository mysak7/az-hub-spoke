resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.dns_zones)
  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

locals {
  vnet_zone_links = flatten([
    for zone_name in var.dns_zones : [
      for vnet_label, vnet in var.linked_vnets : {
        key                  = "${replace(zone_name, ".", "-")}-${vnet_label}"
        zone_name            = zone_name
        vnet_label           = vnet_label
        vnet_id              = vnet.vnet_id
        registration_enabled = vnet.registration_enabled
      }
    ]
  ])
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = { for link in local.vnet_zone_links : link.key => link }

  name                  = "link-${each.value.vnet_label}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_name].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = each.value.registration_enabled
  tags                  = var.tags
}
