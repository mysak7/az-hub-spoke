#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/network"

terraform init \
    -backend-config="resource_group_name=rg-dev-terraform-tfstate" \
    -backend-config="storage_account_name=stdevtfstate5ffa7688" \
    -backend-config="container_name=tfstate-hub-spoke" \
    -backend-config="key=dev-network.tfstate"
