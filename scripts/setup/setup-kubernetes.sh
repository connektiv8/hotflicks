#!/bin/bash
# /scripts/setup/setup-kubernetes.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/init.conf"

# CNI Configuration
readonly CNI_TYPE="calico"  # Can be configured in init.cfg
readonly CNI_VERSION="v3.26.1"  # Version pinning
readonly CNI_CONFIG_DIR="${PROJECT_ROOT}/automation/runtime/core/networking/cni"

setup_cni() {
    local cni_type=$1
    echo "Setting up CNI: ${cni_type}"
    
    case ${cni_type} in
        "calico")
            kubectl apply -f "${CNI_CONFIG_DIR}/calico/calico.yaml"
            # Apply any custom configurations
            kubectl apply -f "${CNI_CONFIG_DIR}/calico/custom-config.yaml"
            ;;
        "flannel")
            kubectl apply -f "${CNI_CONFIG_DIR}/flannel/flannel.yaml"
            ;;
        *)
            echo "Unsupported CNI type: ${cni_type}"
            exit 1
            ;;
    esac
}

setup_control_plane() {
    echo "Setting up Kubernetes control plane..."
    
    # Install required packages
    apk add --no-cache \
        kubeadm \
        kubelet \
        kubectl \
        containerd

    # Initialize control plane
    kubeadm init \
        --pod-network-cidr=10.244.0.0/16 \
        --control-plane-endpoint="k8s-control-plane:6443" \
        --upload-certs

    # Set up kubeconfig
    mkdir -p $HOME/.kube
    cp /etc/kubernetes/admin.conf $HOME/.kube/config
    
    # Set up CNI using local configurations
    setup_cni "${CNI_TYPE}"
}
