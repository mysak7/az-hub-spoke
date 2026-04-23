variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the Hub VNet."
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the Hub VNet."
}

variable "hub_resource_group_name" {
  type        = string
  description = "Resource group containing the Hub VNet."
}

variable "spoke_vnet_id" {
  type        = string
  description = "Resource ID of the Spoke VNet."
}

variable "spoke_vnet_name" {
  type        = string
  description = "Name of the Spoke VNet."
}

variable "spoke_resource_group_name" {
  type        = string
  description = "Resource group containing the Spoke VNet."
}

variable "peering_name_suffix" {
  type        = string
  description = "Suffix identifying the spoke (e.g. app, mgmt) used in peering resource names."
}
