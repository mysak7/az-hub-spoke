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

variable "backend_resource_group_name" {
  description = "Resource group of the Terraform state storage account."
  type        = string
}

variable "backend_storage_account_name" {
  description = "Storage account name holding Terraform state files."
  type        = string
}

variable "backend_container_name" {
  description = "Blob container name for Terraform state files."
  type        = string
}

variable "network_state_key" {
  description = "Blob key for the network layer state file."
  type        = string
  default     = "dev-network.tfstate"
}
