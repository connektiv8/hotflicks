#!/bin/bash
# scripts/setup/update-cni-manifests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${SCRIPT_DIR}/init.conf"

# Load logging functions if they're in a shared library
source "${SCRIPT_DIR}/log-functions.sh"

# CNI Base Configuration
readonly CNI_CONFIG_DIR="${PROJECT_ROOT}/automation/runtime/core/networking/cni"

update_calico_manifests() {
    local version=$1
    local target_dir="${CNI_CONFIG_DIR}/calico"
    
    log_info "Creating Calico manifests version ${version}"

    # Create installation configuration
    cat > "${target_dir}/calico.yaml" << EOL
---
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  registry: ${LOCAL_REGISTRY}
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: ${K8S_POD_CIDR}
      encapsulation: VXLANCrossSubnet
      natOutgoing: true
      nodeSelector: all()
  componentResources:
    - componentName: node
      resourceRequirements:
        requests:
          cpu: 250m
          memory: 256Mi
        limits:
          cpu: 500m
          memory: 512Mi
  typhaMetricsPort: 9093
  nodeMetricsPort: 9091
EOL

    log_success "Created Calico base configuration"

    # Create custom configurations
    cat > "${target_dir}/custom-config.yaml" << EOL
---
apiVersion: operator.tigera.io/v1
kind: InstallationSpec
metadata:
  name: custom-config
spec:
  containerIPForwarding: Enabled
  flexVolumePath: /opt/hotflicks/bin
  nodeUpdateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  logging:
    logseverity: Info
EOL

    log_success "Created Calico custom configuration"
}

update_flannel_manifests() {
    local version=$1
    local target_dir="${CNI_CONFIG_DIR}/flannel"
    
    log_info "Creating Flannel manifests version ${version}"

    cat > "${target_dir}/flannel.yaml" << EOL
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "flannel",
          "delegate": {
            "hairpinMode": true,
            "isDefaultGateway": true
          }
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          }
        }
      ]
    }
  net-conf.json: |
    {
      "Network": "${K8S_POD_CIDR}",
      "Backend": {
        "Type": "vxlan"
      }
    }
EOL

    log_success "Created Flannel configuration"
}

validate_configuration() {
    local errors=0

    # Validate required variables
    if [[ -z "${K8S_POD_CIDR:-}" ]]; then
        log_error "K8S_POD_CIDR is not set in configuration"
        errors=$((errors + 1))
    fi

    if [[ -z "${LOCAL_REGISTRY:-}" ]]; then
        log_error "LOCAL_REGISTRY is not set in configuration"
        errors=$((errors + 1))
    fi

    if [[ -z "${K8S_CNI_TYPE:-}" ]]; then
        log_error "K8S_CNI_TYPE is not set in configuration"
        errors=$((errors + 1))
    fi

    if [[ $errors -gt 0 ]]; then
        log_error "Configuration validation failed with ${errors} error(s)"
        exit 1
    fi
}

create_directories() {
    mkdir -p "${CNI_CONFIG_DIR}/calico"
    mkdir -p "${CNI_CONFIG_DIR}/flannel"
    log_success "Created CNI configuration directories"
}

main() {
    log_info "Starting CNI manifest update process..."
    
    validate_configuration
    create_directories
    
    case ${K8S_CNI_TYPE} in
        "calico")
            update_calico_manifests "${K8S_CNI_VERSION}"
            ;;
        "flannel")
            update_flannel_manifests "${K8S_CNI_VERSION}"
            ;;
        *)
            log_error "Unsupported CNI type: ${K8S_CNI_TYPE}"
            exit 1
            ;;
    esac
    
    log_success "CNI manifests updated successfully"
}

# Execute main function
main "$@"