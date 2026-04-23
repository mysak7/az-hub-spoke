locals {
  prefix      = "hubspoke"
  environment = "dev"
  location    = var.location

  location_short = {
    "westeurope"  = "weu"
    "eastus"      = "eus"
    "eastus2"     = "eus2"
    "westus"      = "wus"
    "northeurope" = "neu"
    "uksouth"     = "uks"
  }[var.location]

  tags = {
    Project     = "az-hub-spoke"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

# ── Hub Network ──────────────────────────────────────────────────────────────

module "hub_network" {
  source = "../../modules/hub_network"

  prefix         = local.prefix
  environment    = local.environment
  location       = local.location
  location_short = local.location_short
  tags           = local.tags
}

# ── Azure Firewall ────────────────────────────────────────────────────────────

module "firewall" {
  source = "../../modules/firewall"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  location_short      = local.location_short
  resource_group_name = module.hub_network.resource_group_name
  firewall_subnet_id  = module.hub_network.firewall_subnet_id
  sku_tier            = "Standard"
  tags                = local.tags
}

# ── Azure Bastion ─────────────────────────────────────────────────────────────

module "bastion" {
  source = "../../modules/bastion"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  location_short      = local.location_short
  resource_group_name = module.hub_network.resource_group_name
  bastion_subnet_id   = module.hub_network.bastion_subnet_id
  sku                 = "Standard"
  tags                = local.tags
}

# ── App Spoke ─────────────────────────────────────────────────────────────────

module "app_spoke" {
  source = "../../modules/spoke_network"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  location_short      = local.location_short
  spoke_name          = "app"
  vnet_cidr           = "10.1.0.0/16"
  firewall_private_ip = module.firewall.firewall_private_ip
  tags                = local.tags

  subnets = {
    "snet-web" = {
      cidr                              = "10.1.1.0/24"
      private_endpoint_network_policies = "Enabled"
      apply_udr                         = true
    }
    "snet-app" = {
      cidr                              = "10.1.2.0/24"
      private_endpoint_network_policies = "Enabled"
      apply_udr                         = true
    }
    "snet-pep" = {
      cidr                              = "10.1.10.0/24"
      private_endpoint_network_policies = "Disabled"
      apply_udr                         = false
    }
  }
}

# ── Management Spoke ──────────────────────────────────────────────────────────

module "mgmt_spoke" {
  source = "../../modules/spoke_network"

  prefix              = local.prefix
  environment         = local.environment
  location            = local.location
  location_short      = local.location_short
  spoke_name          = "mgmt"
  vnet_cidr           = "10.2.0.0/16"
  firewall_private_ip = module.firewall.firewall_private_ip
  tags                = local.tags

  subnets = {
    "snet-tools" = {
      cidr      = "10.2.1.0/24"
      apply_udr = true
    }
    "snet-jump" = {
      cidr      = "10.2.2.0/24"
      apply_udr = true
    }
  }
}

# ── VNet Peering ──────────────────────────────────────────────────────────────

module "hub_app_peering" {
  source = "../../modules/peering"

  hub_vnet_id               = module.hub_network.vnet_id
  hub_vnet_name             = module.hub_network.vnet_name
  hub_resource_group_name   = module.hub_network.resource_group_name
  spoke_vnet_id             = module.app_spoke.vnet_id
  spoke_vnet_name           = module.app_spoke.vnet_name
  spoke_resource_group_name = module.app_spoke.resource_group_name
  peering_name_suffix       = "app"
}

module "hub_mgmt_peering" {
  source = "../../modules/peering"

  hub_vnet_id               = module.hub_network.vnet_id
  hub_vnet_name             = module.hub_network.vnet_name
  hub_resource_group_name   = module.hub_network.resource_group_name
  spoke_vnet_id             = module.mgmt_spoke.vnet_id
  spoke_vnet_name           = module.mgmt_spoke.vnet_name
  spoke_resource_group_name = module.mgmt_spoke.resource_group_name
  peering_name_suffix       = "mgmt"
}

# ── Private DNS ───────────────────────────────────────────────────────────────

module "private_dns" {
  source = "../../modules/private_dns"

  resource_group_name = module.hub_network.resource_group_name
  dns_zones = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]

  linked_vnets = {
    hub = {
      vnet_id              = module.hub_network.vnet_id
      registration_enabled = false
    }
    app = {
      vnet_id              = module.app_spoke.vnet_id
      registration_enabled = false
    }
  }

  tags = local.tags
}
