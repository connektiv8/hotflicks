#!/bin/bash
# scripts/setup/init.sh

set -euo pipefail

# Base directory determination
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly CONFIG_FILE="${SCRIPT_DIR}/init.cfg"

# Load and parse configuration
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: Configuration file not found at ${CONFIG_FILE}"
    exit 1
fi

# Function to parse the configuration file
parse_config() {
    local config_file=$1
    local line
    declare -g -A config_arrays

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue

        if [[ "$line" =~ ^([A-Za-z_]+)\[\]=(.*) ]]; then
            # Handle array items
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Initialize array if not exists
            [[ -z "${config_arrays[$key]+x}" ]] && config_arrays[$key]=""
            
            # Append value to array
            [[ -n "${config_arrays[$key]}" ]] && config_arrays[$key]+="|"
            config_arrays[$key]+="$value"
        elif [[ "$line" =~ ^([A-Za-z_]+)=(.*) ]]; then
            # Handle regular variables
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            # Remove inline comments
            value="${value%%#*}"
            # Trim whitespace
            value="${value## }"
            value="${value%% }"
            declare -g "$key=$value"
        fi
    done < "$config_file"

    # Convert array strings to actual arrays
    for key in "${!config_arrays[@]}"; do
        IFS='|' read -r -a "array_$key" <<< "${config_arrays[$key]}"
    done
}

# Load configuration
parse_config "${CONFIG_FILE}"

# Logging functions using config status types
log_error() {
    echo -e "${STATUS_ERROR}[ERROR]${FORMAT_RESET} $1"
}

log_success() {
    echo -e "${STATUS_SUCCESS}[SUCCESS]${FORMAT_RESET} $1"
}

log_warning() {
    echo -e "${STATUS_WARNING}[WARNING]${FORMAT_RESET} $1"
}

log_info() {
    echo -e "${STATUS_SUCCESS}[INFO]${FORMAT_RESET} $1"
}

# Check if required tools are installed
check_requirements() {
    log_info "Checking required tools..."
    for tool in "${array_REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is required but not installed."
            exit 1
        fi
    done
    log_success "All required tools are installed"
}

# Create directory structure
create_directory_structure() {
    log_info "Creating directory structure..."
    for dir in "${array_DIRECTORIES[@]}"; do
        # Remove leading slash for mkdir
        local dir_path="${dir#/}"
        mkdir -p "${PROJECT_ROOT}/${dir_path}"
        log_success "Created directory: ${dir_path}"
    done
}

# Process YAML templates
process_yaml_templates() {
    local component=$1
    local target_dir=$2

    if [[ -d "${PROJECT_ROOT}/${TEMPLATES_PATH#/}/${component}" ]]; then
        for template in "${PROJECT_ROOT}/${TEMPLATES_PATH#/}/${component}"/*.yaml.template; do
            if [[ -f "$template" ]]; then
                local filename=$(basename "$template" .template)
                envsubst < "$template" > "${target_dir}/${filename}"
                log_success "Processed template: ${filename} for ${component}"
            fi
        done
    fi
}

# Create Kubernetes configs from templates
create_kubernetes_configs() {
    log_info "Creating Kubernetes configurations..."
    for component in "${array_K8S_COMPONENTS[@]}"; do
        local target_dir="${PROJECT_ROOT}/automation/runtime/core/${component}"
        process_yaml_templates "$component" "$target_dir"
    done
}

# Create environment-specific configurations
create_env_configs() {
    log_info "Creating environment-specific configurations..."
    for env in "${array_ENVIRONMENTS[@]}"; do
        for service in "${array_SERVICES[@]}"; do
            local target_dir="${PROJECT_ROOT}/configs/env/${env}/${service}"
            process_yaml_templates "env/${env}/${service}" "$target_dir"
        done
    done
}

# Create Docker configurations
create_docker_configs() {
    log_info "Creating Docker configurations..."
    for env in "${array_DOCKER_ENVIRONMENTS[@]}"; do
        local source_file="${PROJECT_ROOT}/${TEMPLATES_PATH#/}/docker/docker-compose.${env}.yml.template"
        if [[ -f "$source_file" ]]; then
            local target_file="${PROJECT_ROOT}/configs/docker/docker-compose.${env}.yml"
            envsubst < "$source_file" > "$target_file"
            log_success "Created docker-compose.${env}.yml"
        fi
    done
}

# Initialize git repository with proper gitignore
init_git_repository() {
    if [[ ! -d "${PROJECT_ROOT}/.git" ]]; then
        git init "${PROJECT_ROOT}"
        
        cat > "${PROJECT_ROOT}/.gitignore" << 'EOL'
# Environment specific
.env
*.env
.env.*

# IDE files
.idea/
.vscode/
*.swp
*.swo

# Dependency directories
node_modules/
vendor/
__pycache__/
*.pyc

# Build outputs
dist/
build/
*.egg-info/

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Testing
coverage/
.coverage
htmlcov/

# Local development
.DS_Store
Thumbs.db
EOL
        
        log_success "Initialized git repository with .gitignore"
    else
        log_warning "Git repository already initialized"
    fi
}

# Create initial README
create_readme() {
    cat > "${PROJECT_ROOT}/README.md" << 'EOL'
# HotFlicks Platform

## Project Structure

Detailed description of the project structure and components.

## Setup Instructions

1. Prerequisites
2. Development Environment Setup
3. Production Deployment
4. Monitoring Setup

## Configuration

Description of configuration options and environment variables.

## Development

Guidelines for development and contribution.

## Deployment

Instructions for deployment to different environments.

## Monitoring

Details about monitoring and alerting setup.

## License

Project license information.
EOL

    log_success "Created README.md"
}

# Validate environment
validate_environment() {
    log_info "Validating environment..."
    if [[ ! -d "${PROJECT_ROOT}" ]]; then
        log_error "Project root directory not found"
        exit 1
    fi
    if [[ ! -d "${PROJECT_ROOT}/${TEMPLATES_PATH#/}" ]]; then
        log_error "Templates directory not found"
        exit 1
    }
}

# Main execution function
main() {
    log_info "Starting project initialization..."
    
    validate_environment
    check_requirements
    create_directory_structure
    create_kubernetes_configs
    create_env_configs
    create_docker_configs
    init_git_repository
    create_readme
    
    log_success "Project initialization complete!"
    log_info "Next steps:"
    log_info "1. Review generated configurations"
    log_info "2. Update environment-specific variables"
    log_info "3. Run development environment setup: ./scripts/setup/setup-dev.sh"
}

# Execute main function
main "$@"