resource "azurerm_resource_group" "spoke" {
  name     = "rg-${var.prefix}-${var.spoke_name}-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.prefix}-${var.spoke_name}-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                              = "${each.key}-${var.prefix}-${var.environment}-${var.location_short}"
  resource_group_name               = azurerm_resource_group.spoke.name
  virtual_network_name              = azurerm_virtual_network.spoke.name
  address_prefixes                  = [each.value.cidr]
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

resource "azurerm_route_table" "spoke" {
  name                          = "rt-${var.prefix}-${var.spoke_name}-${var.environment}-${var.location_short}"
  location                      = azurerm_resource_group.spoke.location
  resource_group_name           = azurerm_resource_group.spoke.name
  bgp_route_propagation_enabled = false

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if v.apply_udr }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.spoke.id
}
