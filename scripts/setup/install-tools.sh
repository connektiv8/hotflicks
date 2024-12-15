#!/bin/bash
# scripts/setup/install-tools.sh

set -euo pipefail

# Base directory determination
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/init.conf"

# Load configuration file for required tools
source "${CONFIG_FILE}"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

# Check if tool is installed
check_tool() {
    if command -v "$1" &> /dev/null; then
        return 0
    fi
    return 1
}

# Install tools for Linux (Ubuntu/Debian)
install_linux() {
    echo "Installing tools for Linux..."

    # Update package lists
    sudo apt-get update

    # Docker
    if ! check_tool docker; then
        echo "Installing Docker..."
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    fi

    # kubectl
    if ! check_tool kubectl; then
        echo "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    # kustomize
    if ! check_tool kustomize; then
        echo "Installing kustomize..."
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        sudo mv kustomize /usr/local/bin/
    fi

    # git
    if ! check_tool git; then
        echo "Installing git..."
        sudo apt-get install -y git
    fi
}

# Install tools for macOS
install_macos() {
    echo "Installing tools for macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Docker Desktop for Mac
    if ! check_tool docker; then
        echo "Docker Desktop needs to be installed manually on macOS."
        echo "Please visit: https://docs.docker.com/desktop/mac/install/"
        echo "After installation, press any key to continue..."
        read -n 1
    fi

    # Install other tools via Homebrew
    brew install kubectl kustomize git
}

# Provide Docker alternative information
show_docker_alternative() {
    echo "
Alternative: Use Development Container

You can use a pre-configured development container instead of installing tools locally.
To do this:

1. Install Docker only
2. Build the development environment:
   cd /path/to/project
   docker build -t hotflicks-dev -f docker/Dockerfile.dev .
   
3. Run the development container:
   docker run -it --rm -v \$(pwd):/workspace hotflicks-dev

This will provide all required tools in an isolated environment.
"
}

# Main execution
main() {
    local os_type=$(detect_os)
    
    echo "Checking and installing required tools..."
    
    case $os_type in
        "linux")
            install_linux
            ;;
        "macos")
            install_macos
            ;;
        *)
            echo "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
    
    # Verify installations
    echo "Verifying installations..."
    local all_installed=true
    
    for tool in "${array_REQUIRED_TOOLS[@]}"; do
        if check_tool "$tool"; then
            echo "✓ $tool installed"
        else
            echo "✗ $tool installation failed"
            all_installed=false
        fi
    done
    
    if [ "$all_installed" = true ]; then
        echo "All tools successfully installed!"
    else
        echo "Some tools failed to install. Please check the errors above."
        exit 1
    fi
    
    show_docker_alternative
}

main "$@"