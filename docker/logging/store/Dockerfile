# docker/logging/store/Dockerfile
# ------------------------------
# This is the Dockerfile for the logging collector service.
# It uses the official Alpine image as the base image and installs
# Elasticsearch, cURL, and ca-certificates. It copies the Elasticsearch
# configuration files to the container and exposes port 9200.
# The CMD instruction specifies the command to run when the container starts.

FROM alpine:3.21

RUN apk add --no-cache \
    elasticsearch \
    curl \
    ca-certificates

COPY logging/store/conf/elasticsearch.yml /etc/elasticsearch/

EXPOSE 9200

CMD ["elasticsearch", "-Epath.conf=/etc/elasticsearch/"]

