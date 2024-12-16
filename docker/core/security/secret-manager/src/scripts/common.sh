# docker/core/secret-manager/src/scripts/common.sh
#!/bin/bash
# Shared functions used across our scripts

# Logging functions
log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Check if this is the primary node
is_primary_node() {
    # Check HOSTNAME against known primary name
    [[ "${HOSTNAME}" == "vault-0" ]]
}

# Check if Vault is unsealed
is_vault_unsealed() {
    vault status -format=json | jq -r '.sealed' | grep -q 'false'
}

# Wait for primary node to be ready
wait_for_primary() {
    while ! curl -sf "${VAULT_ADDR}/v1/sys/health" >/dev/null; do
        log_info "Waiting for primary node..."
        sleep 5
    done
}