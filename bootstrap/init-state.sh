#!/usr/bin/env bash
# Creates Azure Blob Storage for Terraform remote state.
# Run once before `terraform init` in environments/dev/.
set -euo pipefail

# ── Config (override via env vars) ───────────────────────────────────────────
PREFIX="${PREFIX:-hubspoke}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
LOCATION="${LOCATION:-westeurope}"
LOCATION_SHORT="${LOCATION_SHORT:-weu}"

RG_NAME="rg-${PREFIX}-tfstate-${ENVIRONMENT}-${LOCATION_SHORT}"
SA_NAME="st${PREFIX}tfst$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"
STATE_KEY="dev.terraform.tfstate"

# ── Login check ───────────────────────────────────────────────────────────────
if ! az account show &>/dev/null; then
  echo "Not logged in — run: az login"
  exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
OBJECT_ID=$(az ad signed-in-user show --query id -o tsv 2>/dev/null \
  || az account show --query "user.name" -o tsv)

echo ""
echo "==> Subscription : $SUBSCRIPTION_ID"
echo "==> Resource Group: $RG_NAME"
echo "==> Storage Account: $SA_NAME"
echo "==> Container: $CONTAINER_NAME"
echo ""

# ── Resource Group ────────────────────────────────────────────────────────────
echo "==> Creating resource group..."
az group create \
  --name "$RG_NAME" \
  --location "$LOCATION" \
  --tags Project="$PREFIX" Environment="$ENVIRONMENT" ManagedBy="az-cli" Purpose="terraform-state" \
  --output none

# ── Storage Account ───────────────────────────────────────────────────────────
echo "==> Creating storage account..."
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags Project="$PREFIX" Environment="$ENVIRONMENT" ManagedBy="az-cli" Purpose="terraform-state" \
  --output none

# ── Blob versioning + soft delete ─────────────────────────────────────────────
echo "==> Enabling versioning and soft delete..."
az storage account blob-service-properties update \
  --account-name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --output none

# ── Blob Container ────────────────────────────────────────────────────────────
echo "==> Creating blob container..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --auth-mode login \
  --output none

# ── RBAC: Storage Blob Data Contributor for the current user ──────────────────
echo "==> Assigning Storage Blob Data Contributor role..."
SA_ID=$(az storage account show \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --query id -o tsv)

az role assignment create \
  --assignee-object-id "$(az ad signed-in-user show --query id -o tsv)" \
  --assignee-principal-type User \
  --role "Storage Blob Data Contributor" \
  --scope "$SA_ID" \
  --output none

# ── Output ────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " State storage ready. Paste this into environments/dev/backend.tf:"
echo "============================================================"
cat <<EOF

terraform {
  backend "azurerm" {
    resource_group_name  = "$RG_NAME"
    storage_account_name = "$SA_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "$STATE_KEY"
    use_azuread_auth     = true
  }
}
EOF
echo "============================================================"
echo ""
echo "Then run:  terraform -chdir=environments/dev init -migrate-state"
