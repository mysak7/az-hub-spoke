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
  description = "Resource group in which to deploy Bastion (use the hub RG)."
}

variable "bastion_subnet_id" {
  type        = string
  description = "Resource ID of AzureBastionSubnet."
}

variable "sku" {
  type        = string
  description = "Azure Bastion SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Developer", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, Developer, or Premium."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
