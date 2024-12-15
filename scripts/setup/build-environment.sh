#!/bin/bash
# scripts/setup/build-environment.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/init.cfg"

# Build the build environment
echo "Building build environment..."
docker build -t ${BUILD_IMAGE} -f docker/build-environment/Dockerfile .

# Function to build streaming components
build_streaming() {
    echo "Building streaming components..."
    docker build -t hotflicks-streaming-edge -f docker/streaming/Dockerfile .
}

# Function to build microservices
build_microservices() {
    local services=("api" "frontend" "ml-service" "search-service")
    
    for service in "${services[@]}"; do
        echo "Building $service..."
        docker build -t "hotflicks-${service}" \
            --build-arg SERVICE_NAME="${service}" \
            -f "docker/microservices/Dockerfile.${service}" .
    done
}

# Main execution
main() {
    case "$1" in
        "streaming")
            build_streaming
            ;;
        "services")
            build_microservices
            ;;
        "all")
            build_streaming
            build_microservices
            ;;
        *)
            echo "Usage: $0 {streaming|services|all}"
            exit 1
            ;;
    esac
}

main "$@"