# src/scripts/init-vault.sh
#!/bin/bash
set -euo pipefail

# This script handles the initial setup of a new Vault cluster
# It should only run once when first deploying Vault

source ./common.sh  # For shared functions

log_info "Starting Vault initialization process..."

# Check if we're on the primary node
if ! is_primary_node; then
    log_info "Not primary node, waiting for primary initialization..."
    wait_for_primary
    exit 0
fi

# Initialize Vault
log_info "Initializing Vault..."
INIT_RESPONSE=$(vault operator init -format=json)

# Store the keys securely
# In production, these would be securely distributed to key holders
echo "$INIT_RESPONSE" | jq -r '.root_token' > /vault/data/root_token
echo "$INIT_RESPONSE" | jq -r '.unseal_keys_b64[]' > /vault/data/unseal_keys

# Perform initial unseal
log_info "Performing initial unseal..."
cat /vault/data/unseal_keys | while read key; do
    vault operator unseal "$key"
done

log_info "Vault initialized and unsealed successfully"