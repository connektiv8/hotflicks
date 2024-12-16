# docker/core/secret-manager/src/scripts/setup-replication.sh
#!/bin/bash

set -euo pipefail

source ./common.sh

# This script configures replication between Vault nodes

log_info "Setting up Vault replication..."

if is_primary_node; then
    # Configure primary
    log_info "Configuring primary node..."
    vault write -f sys/replication/performance/primary/enable
    
    # Generate secondary tokens
    for i in {1..2}; do
        SECONDARY_TOKEN=$(vault write sys/replication/performance/primary/secondary-token \
            id="vault-${i}" -format=json | jq -r '.wrap_info.token')
        # Store token securely for secondary nodes
        echo "$SECONDARY_TOKEN" > "/vault/data/secondary_token_${i}"
    done
else
    # Configure secondary
    log_info "Configuring secondary node..."
    NODE_ID="${HOSTNAME#vault-}"
    TOKEN_FILE="/vault/data/secondary_token_${NODE_ID}"
    
    while [ ! -f "$TOKEN_FILE" ]; do
        log_info "Waiting for secondary token..."
        sleep 5
    done
    
    SECONDARY_TOKEN=$(cat "$TOKEN_FILE")
    vault write sys/replication/performance/secondary/enable token="$SECONDARY_TOKEN"
fi