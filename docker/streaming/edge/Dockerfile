# docker/streaming/edge/Dockerfile
# ---------------------

# Author: Christian Bannard
# Created: 2024-12-15

# This Dockerfile is used to build the edge service for the streaming service.
# It installs the necessary packages for streaming and configures the nginx server for streaming.
# It also installs Consul and Vault for service discovery and secrets management.
# The edge service is used to serve video streams to clients.

FROM freebsd:14.2-RELEASE

# Install necessary packages
RUN pkg install -y \
    nginx \
    ffmpeg \
    consul \
    vault \
    curl \
    bash \
    ca_root_nss

# Copy configurations
COPY streaming/edge/conf/nginx.conf /usr/local/etc/nginx/nginx.conf
COPY streaming/edge/conf/consul-client.json /usr/local/etc/consul/client.json
COPY streaming/edge/conf/vault-agent.hcl /usr/local/etc/vault/agent.hcl

# Setup streaming optimizations
COPY streaming/edge/conf/sysctl.conf /etc/sysctl.conf
COPY streaming/edge/conf/loader.conf /boot/loader.conf

EXPOSE 80 443 8500 8200

CMD ["nginx", "-g", "daemon off;"]