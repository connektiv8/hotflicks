# docker/core/monitoring/alerting/Dockerfile

FROM prom/alertmanager:v0.27.0

# Add metadata labels
LABEL maintainer="HotFlicks Platform Team" \
      description="Alert management and notification service" \
      version="1.0"

# Create necessary directories with proper permissions
# Templates directory for custom notification templates
# Config directory for alertmanager configuration
RUN mkdir -p /alertmanager/templates \
    && mkdir -p /alertmanager/config \
    && chown -R nobody:nobody /alertmanager

# Copy configuration files
COPY conf/alertmanager.yaml /alertmanager/config/
COPY conf/templates/ /alertmanager/templates/

# Use non-root user for security
USER nobody

# Expose the Alertmanager web interface and clustering ports
EXPOSE 9093 9094

# Start Alertmanager with our configuration
ENTRYPOINT [ "/bin/alertmanager" ]
CMD [ "--config.file=/alertmanager/config/alertmanager.yml", \
      "--storage.path=/alertmanager", \
      "--web.external-url=http://alertmanager:9093" ]