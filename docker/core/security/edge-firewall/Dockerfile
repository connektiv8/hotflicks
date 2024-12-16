# docker/core/security/edge-firewall/Dockerfile
FROM openbsd:7.6

LABEL maintainer="HotFlicks Platform Team" \
      description="Edge security and firewall service" \
      version="1.0"

# Install necessary packages
RUN pkg_add -U \
    curl \
    ca_certificates \
    python3 \
    py3-pip \
    rsyslog

# Copy configurations
COPY conf/pf.conf /etc/
COPY conf/blacklist.conf /etc/
COPY src/scripts/dynamic-block.py /usr/local/bin/

# Set proper permissions
RUN chmod 600 /etc/pf.conf \
    && chmod 600 /etc/blacklist.conf \
    && chmod 755 /usr/local/bin/dynamic-block.py

# Expose necessary ports
EXPOSE 22 80 443

CMD ["/usr/sbin/pf", "-f", "/etc/pf.conf"]