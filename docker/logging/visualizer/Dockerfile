# docker/logging/visualizer/Dockerfile
# ------------------------------
# This is the Dockerfile for the logging visualizer service.
# It uses the official Alpine image as the base image and installs
# cURL and ca-certificates. It copies the Kibana configuration files
# to the container and exposes port 5601. The CMD instruction specifies
# the command to run when the container starts.

FROM alpine:3.21

RUN apk add --no-cache \
    curl \
    ca-certificates

COPY logging/visualizer/conf/kibana.yml /etc/kibana/

EXPOSE 5601

CMD ["kibana", "-c", "/etc/kibana/kibana.yml"]

