# docker/monitoring/metrics-visualizer/Dockerfile
# Internal metrics visualization for system monitoring and alerting

FROM grafana/grafana:11.4.0-alpine

LABEL maintainer="HotFlicks Platform Team" \
      description="Internal metrics visualization service" \
      service="metrics-visualizer" \
      version="1.0"

# Configure Grafana for internal metrics with security focus
ENV GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin} \
    GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin} \
    GF_USERS_ALLOW_SIGN_UP=false \
    GF_AUTH_ANONYMOUS_ENABLED=false \
    GF_SECURITY_DISABLE_GRAVATAR=true \
    GF_SECURITY_STRICT_TRANSPORT_SECURITY=true \
    GF_SECURITY_COOKIE_SECURE=true \
    GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/etc/grafana/dashboards/system/overview.json \
    GF_DASHBOARDS_MIN_REFRESH_INTERVAL=5s \
    GF_ALERTING_ENABLED=true

# Install plugins specific to system monitoring
RUN grafana-cli plugins install grafana-polystat-panel && \
    grafana-cli plugins install grafana-prometheus-datasource && \
    grafana-cli plugins install grafana-alertmanager-datasource && \
    grafana-cli plugins install grafana-infinity-datasource && \
    grafana-cli plugins install grafana-mongodb-datasource

# Create necessary directories with proper permissions
RUN mkdir -p /etc/grafana/provisioning/{dashboards,datasources,notifiers,alerting} && \
    mkdir -p /etc/grafana/dashboards/{system,alerts} && \
    chown -R grafana:grafana /etc/grafana

# Copy configuration files
COPY conf/grafana.ini /etc/grafana/grafana.ini
COPY conf/provisioning/dashboards/*.yaml /etc/grafana/provisioning/dashboards/
COPY conf/provisioning/datasources/*.yaml /etc/grafana/provisioning/datasources/
COPY conf/provisioning/alerting/*.yaml /etc/grafana/provisioning/alerting/
COPY conf/dashboards/system/*.json /etc/grafana/dashboards/system/

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

EXPOSE 3000 9090

USER grafana

CMD ["grafana-server", \
     "--homepath=/usr/share/grafana", \
     "--config=/etc/grafana/grafana.ini", \
     "--packaging=docker"]