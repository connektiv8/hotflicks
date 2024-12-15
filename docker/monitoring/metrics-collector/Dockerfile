# docker/monitoring/Dockerfile.prometheus
# ------------------------------

# Author: Christian Bannard
# Date: 2024-12-15
# Description: Dockerfile for the Prometheus image
# Usage: docker build -t prometheus:latest -f monitoring/metrics-collector/Dockerfile .

# The Dockerfile for the Prometheus image. 
# It uses the official Alpine image as a base and installs Prometheus from the official release. 
# It also copies the Prometheus configuration files and exposes the default port 9090. 
# The CMD instruction specifies the command to run when the container starts. 
# In this case, it runs the Prometheus binary with the configuration file and storage path as arguments.

FROM alpine:3.21

ARG PROMETHEUS_VERSION

RUN apk add --no-cache \
    curl \
    tar \
    bash \
    && curl -LO "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" \
    && tar xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/ \
    && mkdir /etc/prometheus \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/ \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/ \
    && rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*

COPY monitoring/metrics-collector/conf/prometheus.yml /etc/prometheus/
COPY monitoring/metrics-collector/conf/alerts.yml /etc/prometheus/

EXPOSE 9090

CMD ["/usr/local/bin/prometheus", \
     "--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/prometheus", \
     "--web.console.libraries=/etc/prometheus/console_libraries", \
     "--web.console.templates=/etc/prometheus/consoles"]