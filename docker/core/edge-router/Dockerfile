# docker/core/edge-router/Dockerfile

FROM alpine:3.21

# Add labels for our organization and service metadata
LABEL org.opencontainers.image.vendor="HotFlicks Platform" \
      org.opencontainers.image.title="Edge Router" \
      org.opencontainers.image.description="Edge routing and load balancing service" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.documentation="https://docs.hotflicks.local/edge-router" \
      maintainer="HotFlicks Platform Team"

# Install required system packages
# ca-certificates: needed for HTTPS connections
# tzdata: needed for proper time handling
RUN apk --no-cache add \
    ca-certificates \
    tzdata

# Install Traefik binary with architecture detection
# This ensures our image works across different CPU architectures
RUN set -ex; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        armhf) arch='armv6' ;; \
        aarch64) arch='arm64' ;; \
        x86_64) arch='amd64' ;; \
        riscv64) arch='riscv64' ;; \
        s390x) arch='s390x' ;; \
        ppc64le) arch='ppc64le' ;; \
        *) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    wget --quiet -O /tmp/traefik.tar.gz "https://github.com/traefik/traefik/releases/download/v3.2.2/traefik_v3.2.2_linux_$arch.tar.gz"; \
    tar xzvf /tmp/traefik.tar.gz -C /usr/local/bin traefik; \
    rm -f /tmp/traefik.tar.gz; \
    chmod +x /usr/local/bin/traefik

# Create necessary directories with proper permissions
RUN mkdir -p /etc/traefik/dynamic /etc/traefik/acme /certs /logs && \
    chown -R nobody:nobody /etc/traefik /certs /logs

# Copy our configuration files
COPY conf/traefik.yaml /etc/traefik/
COPY conf/dynamic/ /etc/traefik/dynamic/
COPY conf/provider/ /etc/traefik/provider/

# Set up healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8082/ping || exit 1

# Expose necessary ports
# 80: HTTP
# 443: HTTPS
# 8082: Metrics endpoint for Prometheus
EXPOSE 80 443 8082

# Create volumes for persistent data
VOLUME ["/etc/traefik/acme", "/logs"]

# Switch to non-root user
USER nobody

# Copy and set up entrypoint script
COPY src/scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["traefik"]