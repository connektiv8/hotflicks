#!/bin/bash
# scripts/setup/log-functions.sh

set -euo pipefail

# Import status types from init.conf if not already defined
if [[ -z "${STATUS_ERROR:-}" ]]; then
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "${SCRIPT_DIR}/init.conf"
fi

# Logging functions using status types from init.conf
log_error() {
   echo -e "${STATUS_ERROR}[ERROR]${FORMAT_RESET} $1" >&2
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

log_debug() {
   if [[ "${DEBUG:-false}" == "true" ]]; then
       echo -e "${STATUS_SUCCESS}[DEBUG]${FORMAT_RESET} $1"
   fi
}

# Function to handle script failures
log_fail() {
   log_error "$1"
   exit 1
}

# Function for timestamped logs
log_with_timestamp() {
   local level=$1
   local message=$2
   local timestamp
   timestamp=$(date '+%Y-%m-%d %H:%M:%S')
   
   case $level in
       "ERROR")
           log_error "[$timestamp] $message"
           ;;
       "SUCCESS")
           log_success "[$timestamp] $message"
           ;;
       "WARNING")
           log_warning "[$timestamp] $message"
           ;;
       "INFO")
           log_info "[$timestamp] $message"
           ;;
       "DEBUG")
           log_debug "[$timestamp] $message"
           ;;
       *)
           log_error "[$timestamp] Invalid log level: $level"
           return 1
           ;;
   esac
}

# Function to validate log level
validate_log_level() {
   local level=$1
   case $level in
       "ERROR"|"SUCCESS"|"WARNING"|"INFO"|"DEBUG")
           return 0
           ;;
       *)
           return 1
           ;;
   esac
}

# Example usage:
# log_error "This is an error message"
# log_success "Operation completed successfully"
# log_warning "This is a warning"
# log_info "This is an informational message"
# log_debug "This is a debug message"
# log_with_timestamp "INFO" "This is a timestamped info message"