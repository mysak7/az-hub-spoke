resource "azurerm_resource_group" "hub" {
  name     = "rg-${var.prefix}-hub-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}-hub-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# Azure Firewall requires this exact subnet name
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

# Azure Bastion requires this exact subnet name
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_subnet" "shared" {
  name                 = "snet-shared-${var.prefix}-${var.environment}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.shared_subnet_cidr]
}

resource "azurerm_subnet" "dns" {
  name                 = "snet-dns-${var.prefix}-${var.environment}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.dns_subnet_cidr]
}
