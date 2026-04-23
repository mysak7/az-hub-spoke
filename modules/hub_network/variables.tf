variable "prefix" {
  type        = string
  description = "Project prefix used in all resource names."
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "location_short" {
  type        = string
  description = "Short region code for name suffixes (e.g. weu)."
}

variable "vnet_cidr" {
  type        = string
  description = "Address space for the Hub VNet."
  default     = "10.0.0.0/16"
}

variable "firewall_subnet_cidr" {
  type        = string
  description = "CIDR for AzureFirewallSubnet (must be /26 or larger)."
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR for AzureBastionSubnet (must be /26 or larger)."
  default     = "10.0.2.0/26"
}

variable "shared_subnet_cidr" {
  type        = string
  description = "CIDR for the Shared Services subnet."
  default     = "10.0.3.0/24"
}

variable "dns_subnet_cidr" {
  type        = string
  description = "CIDR for the DNS subnet."
  default     = "10.0.4.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
