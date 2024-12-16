# docker/core/monitoring/logging/store/Dockerfile

FROM elasticsearch:8.16.1

# Add metadata labels
LABEL maintainer="HotFlicks Platform Team" \
      description="Log storage and search service" \
      version="1.0"

# Copy configuration files
COPY conf/elasticsearch.yml /usr/share/elasticsearch/config/
COPY conf/jvm.options /usr/share/elasticsearch/config/
COPY conf/log4j2.properties /usr/share/elasticsearch/config/

# Set up necessary permissions
RUN chmod -R 777 /usr/share/elasticsearch/data \
    && chmod -R 777 /usr/share/elasticsearch/logs

# Expose Elasticsearch ports
EXPOSE 9200 9300

# Set environment variables
ENV discovery.type=single-node \
    ES_JAVA_OPTS="-Xms2g -Xmx2g"

# No need to specify user as the base image handles it