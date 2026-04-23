variable "location" {
  type        = string
  description = "Azure region for the state storage resources."
  default     = "westeurope"
}

variable "prefix" {
  type        = string
  description = "Short project prefix used in resource names (no hyphens, max 8 chars)."
  default     = "hubspoke"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "location_short" {
  type        = string
  description = "Short region code appended to resource names."
  default     = "weu"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}
