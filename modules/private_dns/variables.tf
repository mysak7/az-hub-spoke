variable "resource_group_name" {
  type        = string
  description = "Resource group in which to create the Private DNS zones."
}

variable "dns_zones" {
  type        = list(string)
  description = "List of Private DNS zone names to create."
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
}

variable "linked_vnets" {
  type = map(object({
    vnet_id              = string
    registration_enabled = bool
  }))
  description = "Map of label → VNet to link to every DNS zone. Label is used in link resource names."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources."
  default     = {}
}
