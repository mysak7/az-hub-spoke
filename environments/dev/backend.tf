# LOCAL BACKEND (default — good for local dev and terraform validate/plan)
# Switch to the azurerm block below after running bootstrap/.
terraform {
  backend "local" {}
}

# REMOTE BACKEND — uncomment after `cd ../../bootstrap && terraform apply`
# Copy the `backend_config_snippet` output to fill in storage_account_name.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-hubspoke-tfstate-dev-weu"
#     storage_account_name = "sthubspoketfst<suffix>"
#     container_name       = "tfstate"
#     key                  = "dev.terraform.tfstate"
#     use_azuread_auth     = true
#   }
# }
