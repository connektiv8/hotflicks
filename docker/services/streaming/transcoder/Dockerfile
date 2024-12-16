# docker/streaming/transcoder/Dockerfile
# ---------------------

# Author: Christian Bannard
# Created: 2024-12-15

# This Dockerfile is used to build the transcoder service for the streaming service.
# It installs the necessary packages for streaming and configures the nginx server for streaming.
# It also optimizes the FreeBSD operating system for streaming.
# The transcoder service is used to transcode video streams to different formats.

FROM freebsd:14.2-RELEASE

# Install necessary packages for streaming
RUN pkg install -y \
    nginx \
    ffmpeg \
    openssl \
    bash

# Configure nginx for streaming
COPY streaming/transcoder/conf/nginx.conf /usr/local/etc/nginx/nginx.conf

# Optimize FreeBSD for streaming
COPY streaming/transcoder/conf/sysctl.conf /etc/sysctl.conf
COPY streaming/transcoder/conf/loader.conf /boot/loader.conf

WORKDIR /app

CMD ["nginx", "-g", "daemon off;"]