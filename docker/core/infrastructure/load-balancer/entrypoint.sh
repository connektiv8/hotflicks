#!/bin/sh

# docker/core/infrastructure/load-balancer/entrypoint.sh

# -------------------------------------------------------------------------------------------------
# Traefik Entrypoint Script
# -------------------------------------------------------------------------------------------------
# This script is the entrypoint for the Traefik container. It is responsible for setting up the
# environment and executing the Traefik binary with the provided arguments.
# -------------------------------------------------------------------------------------------------
# Author: Christian Bannard
# Date: 2024-12-26

# This script is based on the official Traefik entrypoint script, with the following changes:
# - Custom configuration support
# - Permissions handling for sensitive files
# - Improved logging and error handling
# - Better command execution handling
# - Simplified and cleaned up code
# -------------------------------------------------------------------------------------------------


set -e

# First, check if the first argument starts with '-'
# This allows for passing Traefik options like "-f" or "--config"
if [ "${1#-}" != "$1" ]; then
    set -- traefik "$@"
fi

# Check if the first argument is a valid Traefik command
# This enables commands like "docker run traefik version"
if traefik "$1" --help >/dev/null 2>&1; then
    set -- traefik "$@"
else
    echo "= '$1' is not a Traefik command: assuming shell execution." 1>&2
fi

# Our custom initialization steps
# Only run these if we're starting Traefik normally
if [ "$1" = "traefik" ]; then
    # Check and apply custom configuration if provided
    if [ -f "/etc/traefik/custom/traefik.yaml" ]; then
        cp /etc/traefik/custom/traefik.yaml /etc/traefik/traefik.yaml
    fi

    # Ensure proper permissions on sensitive files
    chmod 600 /etc/traefik/traefik.yaml
    # Only try to set permissions on certificates if they exist
    if [ -d "/certs" ]; then
        find /certs -type f -exec chmod 600 {} + 2>/dev/null || true
    fi
fi

# Execute the final command
exec "$@"