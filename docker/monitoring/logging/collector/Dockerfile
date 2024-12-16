# docker/core/monitoring/logging/collector/Dockerfile

FROM fluent/fluent-bit:3.2.2

# Add metadata labels
LABEL maintainer="HotFlicks Platform Team" \
      description="Log collection and forwarding service" \
      version="1.0"

# Copy configuration files
COPY conf/fluent-bit.conf /fluent-bit/etc/
COPY conf/parsers.conf /fluent-bit/etc/
COPY conf/plugins.conf /fluent-bit/etc/

# Create necessary directories
RUN mkdir -p /fluent-bit/etc/rules \
    && mkdir -p /fluent-bit/etc/scripts

# Expose the monitoring port
EXPOSE 2020

# No need to specify user as the base image handles it

CMD ["/fluent-bit/bin/fluent-bit", "-c", "/fluent-bit/etc/fluent-bit.conf"]