#!/usr/bin/env bash
set -euo pipefail

az group create \
    --name rg-dev-terraform-tfstate \
    --location swedencentral

az storage account create \
    --name stdevtfstate5ffa7688 \
    --resource-group rg-dev-terraform-tfstate \
    --location swedencentral \
    --sku Standard_LRS \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false

az storage container create \
    --name tfstate-hub-spoke \
    --account-name stdevtfstate5ffa7688 \
    --auth-mode login

az role assignment create \
    --assignee-object-id "$(az ad signed-in-user show --query id -o tsv)" \
    --assignee-principal-type User \
    --role "Storage Blob Data Contributor" \
    --scope "$(az storage account show --name stdevtfstate5ffa7688 --resource-group rg-dev-terraform-tfstate --query id -o tsv)"
