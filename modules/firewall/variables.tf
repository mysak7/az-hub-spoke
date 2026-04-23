variable "prefix" {
  type        = string
  description = "Project prefix."
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
  description = "Short region code."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group in which to deploy the firewall (use the hub RG)."
}

variable "firewall_subnet_id" {
  type        = string
  description = "Resource ID of AzureFirewallSubnet."
}

variable "sku_tier" {
  type        = string
  description = "Azure Firewall SKU tier."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Basic, Standard, or Premium."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
