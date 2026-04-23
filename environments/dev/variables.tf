variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID."
}

variable "location" {
  type        = string
  description = "Primary Azure region for all resources."
  default     = "westeurope"
}
