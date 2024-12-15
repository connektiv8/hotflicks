# docker/logging/collector/Dockerfile
# ------------------------------
# This is the Dockerfile for the logging collector service. 
# It uses the official Alpine image as the base image and installs 
# Fluent Bit, cURL, and ca-certificates. It copies the Fluent Bit 
# configuration files to the container and exposes port 24224. 
# The CMD instruction specifies the command to run when the container starts.

FROM alpine:3.21

RUN apk add --no-cache \
    fluent-bit \
    curl \
    ca-certificates

COPY logging/collector/conf/fluent-bit.conf /etc/fluent-bit/
COPY logging/collector/conf/parsers.conf /etc/fluent-bit/

EXPOSE 24224

CMD ["fluent-bit", "-c", "/etc/fluent-bit/fluent-bit.conf"]