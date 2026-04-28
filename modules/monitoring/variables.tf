variable "prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "location_short" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy monitoring resources into (hub RG)."
}

variable "firewall_id" {
  type        = string
  description = "Resource ID of the Azure Firewall."
}

variable "bastion_id" {
  type        = string
  description = "Resource ID of Azure Bastion."
}

variable "spoke_nsg_ids" {
  type        = map(string)
  description = "Map of spoke name → NSG resource ID for flow log enablement."
  default     = {}
}

variable "alert_email" {
  type        = string
  description = "Email address for monitoring alerts."
}

variable "log_retention_days" {
  type        = number
  description = "Log Analytics workspace and flow log retention in days."
  default     = 30
}
