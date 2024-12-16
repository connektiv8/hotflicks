# docker/core/monitoring/logging/visualization/Dockerfile

FROM kibana:8.16.1

# Add metadata labels
LABEL maintainer="HotFlicks Platform Team" \
      description="Log visualization and analysis service" \
      version="1.0"

# Copy configuration
COPY conf/kibana.yaml /usr/share/kibana/config/

# Expose Kibana port
EXPOSE 5601