#!/usr/bin/env bash
set -euo pipefail

terraform init \
    -backend-config="resource_group_name=rg-dev-terraform-tfstate" \
    -backend-config="storage_account_name=stdevterraformtfstate" \
    -backend-config="container_name=tfstate-hub-spoke" \
    -backend-config="key=dev.terraform.tfstate"
