# docker/core/monitoring/tracing/Dockerfile

FROM jaegertracing/all-in-one:1.64.0

# Add metadata labels
LABEL maintainer="HotFlicks Platform Team" \
      description="Distributed tracing service" \
      version="1.0"

# Copy configuration if needed
COPY conf/jaeger.yaml /etc/jaeger/

# Expose ports
EXPOSE 5775/udp 6831/udp 6832/udp 5778 14250 14268 14269 16686

# Environment variables for configuration
ENV SPAN_STORAGE_TYPE="elasticsearch" \
    ES_SERVER_URLS="http://elasticsearch:9200" \
    ES_USERNAME=${ES_USERNAME} \
    ES_PASSWORD=${ES_PASSWORD}