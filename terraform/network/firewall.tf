resource "azurerm_public_ip" "firewall" {
  name                = "pip-${var.environment}-${var.location_short}-afw"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_public_ip" "firewall_mgmt" {
  name                = "pip-${var.environment}-${var.location_short}-afw-mgmt"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = "afwp-${var.environment}-${var.location_short}"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  sku                 = "Basic"
  tags                = local.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "rcg-${var.environment}-${var.location_short}"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  network_rule_collection {
    name     = "nrc-allow-outbound-internet"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-http-https"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }

    rule {
      name                  = "allow-dns"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = "afw-${var.environment}-${var.location_short}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  firewall_policy_id  = azurerm_firewall_policy.this.id
  tags                = local.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  management_ip_configuration {
    name                 = "mgmt-ipconfig"
    subnet_id            = azurerm_subnet.hub_firewall_mgmt.id
    public_ip_address_id = azurerm_public_ip.firewall_mgmt.id
  }
}
