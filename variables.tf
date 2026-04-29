variable "subscription_id" {
  description = "Azure Subscription ID."
  type        = string
}

variable "environment" {
  description = "The environment for which the resources are being created (e.g., dev, prd)."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "location_short" {
  description = "A shortened version of the location, used for naming conventions."
  type        = string
}

variable "alert_email" {
  description = "Email address for Azure Monitor alert notifications."
  type        = string
}
