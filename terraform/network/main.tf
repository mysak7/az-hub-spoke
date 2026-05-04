terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.20.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  tags = {
    Project     = "az-hub-spoke"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  app_subnet_config = {
    web = {
      name                              = "sn-web"
      cidr                              = "10.1.1.0/24"
      private_endpoint_network_policies = "Enabled"
      apply_udr                         = true
    }
    app = {
      name                              = "sn-app"
      cidr                              = "10.1.2.0/24"
      private_endpoint_network_policies = "Enabled"
      apply_udr                         = true
    }
    pep = {
      name                              = "sn-pep"
      cidr                              = "10.1.10.0/24"
      private_endpoint_network_policies = "Disabled"
      apply_udr                         = false
    }
  }

  mgmt_subnet_config = {
    tools = { name = "sn-tools", cidr = "10.2.1.0/24" }
    jump  = { name = "sn-jump", cidr = "10.2.2.0/24" }
  }
}

resource "azurerm_resource_group" "network" {
  name     = "az-hub-spoke-${var.environment}-network"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.environment}-${var.location_short}-hub"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_virtual_network" "app" {
  name                = "vnet-${var.environment}-${var.location_short}-app"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.tags
}

resource "azurerm_virtual_network" "mgmt" {
  name                = "vnet-${var.environment}-${var.location_short}-mgmt"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.2.0.0/16"]
  tags                = local.tags
}

# AzureFirewallSubnet and AzureBastionSubnet are fixed names required by Azure
resource "azurerm_subnet" "hub_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_subnet" "hub_shared" {
  name                 = "sn-shared"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "hub_dns" {
  name                 = "sn-dns"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.4.0/24"]
}

resource "azurerm_subnet" "app" {
  for_each = local.app_subnet_config

  name                              = each.value.name
  resource_group_name               = azurerm_resource_group.network.name
  virtual_network_name              = azurerm_virtual_network.app.name
  address_prefixes                  = [each.value.cidr]
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

resource "azurerm_subnet" "webapps" {
  name                 = "snet-webapps"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.1.4.0/24"]

  delegation {
    name = "app-service"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "mgmt" {
  for_each = local.mgmt_subnet_config

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.mgmt.name
  address_prefixes     = [each.value.cidr]
}

resource "azurerm_route_table" "app" {
  name                          = "rt-${var.environment}-${var.location_short}-app"
  location                      = azurerm_resource_group.network.location
  resource_group_name           = azurerm_resource_group.network.name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_route_table" "mgmt" {
  name                          = "rt-${var.environment}-${var.location_short}-mgmt"
  location                      = azurerm_resource_group.network.location
  resource_group_name           = azurerm_resource_group.network.name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  route {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "app" {
  for_each = { for k, v in local.app_subnet_config : k => v if v.apply_udr }

  subnet_id      = azurerm_subnet.app[each.key].id
  route_table_id = azurerm_route_table.app.id
}

resource "azurerm_subnet_route_table_association" "mgmt" {
  for_each = azurerm_subnet.mgmt

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.mgmt.id
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-${var.environment}-${var.location_short}-app"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-${var.environment}-${var.location_short}-mgmt"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  for_each = azurerm_subnet.app

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  for_each = azurerm_subnet.mgmt

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

resource "azurerm_virtual_network_peering" "hub_to_app" {
  name                         = "peer-hub-to-app"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.app.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "app_to_hub" {
  name                         = "peer-app-to-hub"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.app.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_mgmt" {
  name                         = "peer-hub-to-mgmt"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.mgmt.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "mgmt_to_hub" {
  name                         = "peer-mgmt-to-hub"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.mgmt.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  use_remote_gateways          = false
}
