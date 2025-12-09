#!/usr/bin/env zsh

# Azure Terraform State Storage Setup with ADLS Gen2 and Versioning enabled
# This script creates an Azure resource group, a Storage Account with Hierarchical
# Namespace (ADLS Gen2), enables blob versioning, and creates a container for
# Terraform remote state. It also outputs the backend config values.

set -euo pipefail

# ---------- Configuration (override via env vars or flags) ----------
RESOURCE_GROUP="rg-terraform-state"
LOCATION="centralus"
STORAGE_ACCOUNT="tfstatesaazinfra"
CONTAINER_NAME="tf-state"
SUBSCRIPTION="5462bdf5-9d7e-449f-9a32-61b4002196f6"
# Mode: hns | nonhns | both
MODE=${MODE:-"hns"}
# Retention days for soft delete policies
DELETE_RETENTION_DAYS=${DELETE_RETENTION_DAYS:-7}
CONTAINER_DELETE_RETENTION_DAYS=${CONTAINER_DELETE_RETENTION_DAYS:-7}

# ---------- Helpers ----------
usage() {
	cat <<EOF
Usage: ./terrafromsa.sh [options]

Options (can also be set via env vars):
	-g, --resource-group   Resource group name (default: $RESOURCE_GROUP)
	-l, --location         Azure region (default: $LOCATION)
	-s, --storage-account  Storage account name (default: random tfstateXXXX)
	-c, --container        Container name (default: $CONTAINER_NAME)
	-u, --subscription     Subscription ID or name (default: current context)
	-m, --mode             hns | nonhns | both (default: $MODE)
	    --delete-days      Blob delete retention days (default: $DELETE_RETENTION_DAYS)
	    --container-delete-days Container delete retention days (default: $CONTAINER_DELETE_RETENTION_DAYS)
	-h, --help             Show this help message

Examples:
	RESOURCE_GROUP=myrg LOCATION=westeurope ./terrafromsa.sh
	./terrafromsa.sh -g myrg -l westeurope -s mytfstateacct -c tfstate -m nonhns
	./terrafromsa.sh -m both --delete-days 14 --container-delete-days 14
EOF
}

while [[ ${#} -gt 0 ]]; do
	case "$1" in
		-g|--resource-group) RESOURCE_GROUP="$2"; shift 2;;
		-l|--location) LOCATION="$2"; shift 2;;
		-s|--storage-account) STORAGE_ACCOUNT="$2"; shift 2;;
		-c|--container) CONTAINER_NAME="$2"; shift 2;;
		-u|--subscription) SUBSCRIPTION="$2"; shift 2;;
		-m|--mode) MODE="$2"; shift 2;;
		--delete-days) DELETE_RETENTION_DAYS="$2"; shift 2;;
		--container-delete-days) CONTAINER_DELETE_RETENTION_DAYS="$2"; shift 2;;
		-h|--help) usage; exit 0;;
		*) echo "Unknown option: $1"; usage; exit 1;;
	esac
done

# Ensure az CLI is available
if ! command -v az >/dev/null 2>&1; then
	echo "Azure CLI (az) not found. Install from https://aka.ms/azcli"
	exit 1
fi

# Login if not already
if ! az account show >/dev/null 2>&1; then
	echo "Logging into Azure..."
	az login --only-show-errors >/dev/null
fi

# Set subscription if provided
if [[ -n "$SUBSCRIPTION" ]]; then
	az account set --subscription "$SUBSCRIPTION"
fi

echo "Using subscription: $(az account show --query name -o tsv)"

echo "Creating resource group: $RESOURCE_GROUP ($LOCATION)"
az group create \
	--name "$RESOURCE_GROUP" \
	--location "$LOCATION" \
	--output none

# Storage account names must be globally unique and 3-24 lowercase alphanumerics
STORAGE_ACCOUNT_LOWER=$(echo "$STORAGE_ACCOUNT" | tr '[:upper:]' '[:lower:]')

if [[ "$MODE" == "hns" || "$MODE" == "both" ]]; then
	echo "Creating storage account: $STORAGE_ACCOUNT_LOWER (ADLS Gen2)"
	az storage account create \
			--name "$STORAGE_ACCOUNT_LOWER" \
			--resource-group "$RESOURCE_GROUP" \
			--location "$LOCATION" \
			--sku Standard_LRS \
			--kind StorageV2 \
			--enable-hierarchical-namespace true \
			--min-tls-version TLS1_2 \
			--allow-blob-public-access false \
			--output none

	echo "Configuring soft delete (versioning unsupported for HNS)"
	az storage account blob-service-properties update \
		--account-name "$STORAGE_ACCOUNT_LOWER" \
		--resource-group "$RESOURCE_GROUP" \
		--enable-delete-retention true \
		--delete-retention-days "$DELETE_RETENTION_DAYS" \
		--enable-container-delete-retention true \
		--container-delete-retention-days "$CONTAINER_DELETE_RETENTION_DAYS" \
		--output none
fi

if [[ "$MODE" == "nonhns" || "$MODE" == "both" ]]; then
	NONHNS_ACCOUNT_LOWER="${STORAGE_ACCOUNT_LOWER}nhs"
	echo "Creating storage account: $NONHNS_ACCOUNT_LOWER (Blob versioning supported)"
	az storage account create \
			--name "$NONHNS_ACCOUNT_LOWER" \
			--resource-group "$RESOURCE_GROUP" \
			--location "$LOCATION" \
			--sku Standard_LRS \
			--kind StorageV2 \
			--min-tls-version TLS1_2 \
			--allow-blob-public-access false \
			--output none

	echo "Enabling blob versioning and soft delete on non-HNS account"
	az storage account blob-service-properties update \
		--account-name "$NONHNS_ACCOUNT_LOWER" \
		--resource-group "$RESOURCE_GROUP" \
		--enable-versioning true \
		--enable-delete-retention true \
		--delete-retention-days "$DELETE_RETENTION_DAYS" \
		--enable-container-delete-retention true \
		--container-delete-retention-days "$CONTAINER_DELETE_RETENTION_DAYS" \
		--output none
fi


if [[ "$MODE" == "hns" || "$MODE" == "both" ]]; then
  echo "Retrieving HNS storage account key"
  ACCOUNT_KEY=$(az storage account keys list \
	  --account-name "$STORAGE_ACCOUNT_LOWER" \
	  --resource-group "$RESOURCE_GROUP" \
	  --query "[0].value" -o tsv)

  echo "Creating blob container: $CONTAINER_NAME on $STORAGE_ACCOUNT_LOWER"
  az storage container create \
	  --name "$CONTAINER_NAME" \
	  --account-name "$STORAGE_ACCOUNT_LOWER" \
	  --account-key "$ACCOUNT_KEY" \
	  --auth-mode key \
	  --public-access off \
	  --output none
fi

if [[ "$MODE" == "nonhns" || "$MODE" == "both" ]]; then
  echo "Retrieving non-HNS storage account key"
  NONHNS_KEY=$(az storage account keys list \
	  --account-name "$NONHNS_ACCOUNT_LOWER" \
	  --resource-group "$RESOURCE_GROUP" \
	  --query "[0].value" -o tsv)

  echo "Creating blob container: $CONTAINER_NAME on $NONHNS_ACCOUNT_LOWER"
  az storage container create \
	  --name "$CONTAINER_NAME" \
	  --account-name "$NONHNS_ACCOUNT_LOWER" \
	  --account-key "$NONHNS_KEY" \
	  --auth-mode key \
	  --public-access off \
	  --output none
fi

if [[ "$MODE" == "hns" || "$MODE" == "both" ]]; then
	echo "Fetching primary blob endpoint (HNS)"
	BLOB_ENDPOINT=$(az storage account show \
			--name "$STORAGE_ACCOUNT_LOWER" \
			--resource-group "$RESOURCE_GROUP" \
			--query "primaryEndpoints.blob" -o tsv)
fi

if [[ "$MODE" == "nonhns" || "$MODE" == "both" ]]; then
	echo "Fetching primary blob endpoint (non-HNS)"
	BLOB_ENDPOINT_NONHNS=$(az storage account show \
			--name "$NONHNS_ACCOUNT_LOWER" \
			--resource-group "$RESOURCE_GROUP" \
			--query "primaryEndpoints.blob" -o tsv)
fi

echo "Done. Backend configuration values:"
if [[ "$MODE" == "hns" ]]; then
	cat <<BACKEND
resource_group_name = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT_LOWER"
container_name       = "$CONTAINER_NAME"
key                  = "terraform.tfstate"
BACKEND
elif [[ "$MODE" == "nonhns" ]]; then
	cat <<BACKEND
resource_group_name = "$RESOURCE_GROUP"
storage_account_name = "$NONHNS_ACCOUNT_LOWER"
container_name       = "$CONTAINER_NAME"
key                  = "terraform.tfstate"
BACKEND
else
	echo "HNS account:"
	cat <<BACKEND
resource_group_name = "$RESOURCE_GROUP"
storage_account_name = "$STORAGE_ACCOUNT_LOWER"
container_name       = "$CONTAINER_NAME"
key                  = "terraform.tfstate"
BACKEND
	echo "Non-HNS (versioned) account:"
	cat <<BACKEND
resource_group_name = "$RESOURCE_GROUP"
storage_account_name = "$NONHNS_ACCOUNT_LOWER"
container_name       = "$CONTAINER_NAME"
key                  = "terraform.tfstate"
BACKEND
fi

echo
echo "Example Terraform backend.tf configuration:"
cat <<TF
terraform {
	backend "azurerm" {
		resource_group_name  = "$RESOURCE_GROUP"
		storage_account_name = "
BACKEND_PLACEHOLDER
"
		container_name       = "$CONTAINER_NAME"
		key                  = "terraform.tfstate"
		use_azurerm          = true
	}
}
TF

echo
echo "Quick tips:"
echo "- To use Azure AD auth for backend (no keys), ensure you're logged in with 'az login' and set 'use_azurerm = true'."
echo "- For RBAC, grant roles like 'Storage Blob Data Contributor' to your principal on the storage account."
echo "- Blob versioning is not supported when Hierarchical Namespace (ADLS Gen2) is enabled. Soft delete policies are configured instead."
if [[ -n "${BLOB_ENDPOINT:-}" ]]; then echo "- Blob endpoint (HNS): $BLOB_ENDPOINT"; fi
if [[ -n "${BLOB_ENDPOINT_NONHNS:-}" ]]; then echo "- Blob endpoint (non-HNS): $BLOB_ENDPOINT_NONHNS"; fi


