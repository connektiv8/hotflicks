#!/bin/bash
# docker/core/secret-manager/src/scripts/unseal.sh
set -euo pipefail

# Import our shared functions
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

log_info "Starting Vault unseal process..."

# Define paths relative to project root
VAULT_DATA_DIR="/vault/data"
UNSEAL_KEYS_FILE="${VAULT_DATA_DIR}/unseal_keys"

# Check if vault is already unsealed
if is_vault_unsealed; then
    log_info "Vault already unsealed, no action needed"
    exit 0
fi

# Wait for unseal keys to be available
while [ ! -f "${UNSEAL_KEYS_FILE}" ]; do
    log_info "Waiting for unseal keys..."
    sleep 5
done

# Perform unseal operation
log_info "Unsealing Vault..."
cat "${UNSEAL_KEYS_FILE}" | while read key; do
    vault operator unseal "$key"
done

log_info "Vault unsealed successfully"