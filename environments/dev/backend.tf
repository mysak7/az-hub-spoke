terraform {
  backend "azurerm" {
    # Run `terraform -chdir=../../bootstrap apply` first to provision the storage account,
    # then copy the `backend_config_snippet` output values into this block.
    resource_group_name  = "rg-hubspoke-tfstate-dev-weu"
    storage_account_name = "sthubspoketfst<suffix>" # replace with bootstrap output
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}
