resource "azurerm_public_ip" "bastion" {
  name                = "pip-${var.environment}-${var.location_short}-bas"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "bas-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "Standard"
  tags                = local.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.hub_bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
