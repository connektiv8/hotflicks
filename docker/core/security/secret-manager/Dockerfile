# docker/core/secret-manager/Dockerfile

FROM alpine:3.21

# Add metadata for better container management and documentation
LABEL maintainer="HotFlicks Platform Team" \
      description="Secret management and encryption service" \
      service="secret-manager" \
      version="1.0"

# The version of Vault we're installing needs to be easily updatable
ARG VAULT_VERSION="1.18.2"

# Environment variables affect Vault's runtime behavior
ENV VAULT_ADDR="http://127.0.0.1:8200" \
    # Disable Vault from storing its unseal key (we'll manage this securely)
    VAULT_DISABLE_MLOCK=true \
    # The cluster address for Vault communication
    VAULT_CLUSTER_ADDR="https://0.0.0.0:8201" \
    # Log level can be adjusted per environment
    VAULT_LOG_LEVEL=info

# Install required system packages
# curl: for downloading Vault
# jq: for JSON processing
# openssl: for TLS/certificate handling
# tzdata: for proper time handling
# su-exec: for stepping down from root
RUN apk add --no-cache \
    curl \
    jq \
    openssl \
    tzdata \
    su-exec \
    dumb-init

# Download and install Vault
RUN set -eux; \
    # Download the Vault binary
    curl -Lo /tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"; \
    # Install unzip just for this operation
    apk add --no-cache --virtual .unzip-deps unzip; \
    # Extract Vault
    unzip /tmp/vault.zip -d /bin; \
    # Clean up
    rm -f /tmp/vault.zip; \
    apk del .unzip-deps; \
    # Create Vault user and group
    addgroup vault; \
    adduser -S -G vault vault; \
    # Create necessary directories
    mkdir -p /vault/logs /vault/file /vault/config; \
    # Set ownership and permissions
    chown -R vault:vault /vault; \
    chmod 755 /vault

# Copy configuration files
COPY conf/server.conf /vault/config/server.hcl
COPY conf/auth/ /vault/config/auth/
COPY conf/policies/ /vault/config/policies/

# Copy initialization and helper scripts
COPY src/scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY src/scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

# Set proper permissions on scripts
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    /usr/local/bin/healthcheck.sh

# Create a volume for persistent storage
VOLUME /vault/file

# Expose the Vault ports
# 8200: API and UI access
# 8201: Internal cluster communication
EXPOSE 8200 8201

# Set up healthcheck
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
    CMD /usr/local/bin/healthcheck.sh

# Use dumb-init as the entry point to handle signals properly
ENTRYPOINT ["dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]

# Default to running the server
CMD ["server"]