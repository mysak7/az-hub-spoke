variable "prefix" {
  type        = string
  description = "Project prefix used in all resource names."
}

variable "environment" {
  type        = string
  description = "Deployment environment."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "location_short" {
  type        = string
  description = "Short region code for name suffixes."
}

variable "spoke_name" {
  type        = string
  description = "Spoke identifier (e.g. app, mgmt)."
}

variable "vnet_cidr" {
  type        = string
  description = "Address space for this spoke VNet."
}

variable "subnets" {
  type = map(object({
    cidr                              = string
    private_endpoint_network_policies = optional(string, "Enabled")
    apply_udr                         = optional(bool, true)
  }))
  description = "Map of subnet logical name → configuration."
}

variable "firewall_private_ip" {
  type        = string
  description = "Private IP of the Azure Firewall; used as the next-hop in spoke UDRs."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
