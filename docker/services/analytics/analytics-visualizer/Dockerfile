# docker/apps/analytics-visualizer/Dockerfile
# User-facing analytics platform for viewer statistics and recommendations

FROM grafana/grafana:11.4.0-alpine

LABEL maintainer="HotFlicks Platform Team" \
      description="User-facing analytics visualization service" \
      service="analytics-visualizer" \
      version="1.0"

# Configure Grafana for user-facing analytics with secure defaults
ENV GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER:-admin} \
    GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin} \
    GF_USERS_ALLOW_SIGN_UP=false \
    GF_AUTH_ANONYMOUS_ENABLED=true \
    GF_AUTH_ANONYMOUS_ORG_NAME=HotFlicks \
    GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH=/etc/grafana/dashboards/user_analytics.json \
    GF_FEATURE_TOGGLES_ENABLE="publicDashboards" \
    GF_AUTH_JWT_ENABLED=true \
    GF_AUTH_JWT_HEADER_NAME="X-JWT-Token" \
    GF_DASHBOARDS_MIN_REFRESH_INTERVAL=1m

# Install plugins specific to user analytics visualization
RUN grafana-cli plugins install grafana-piechart-panel && \
    grafana-cli plugins install grafana-worldmap-panel && \
    grafana-cli plugins install grafana-clock-panel && \
    grafana-cli plugins install grafana-timestream-datasource && \
    grafana-cli plugins install grafana-heatmap-panel

# Create necessary directories with proper permissions
RUN mkdir -p /etc/grafana/provisioning/{dashboards,datasources,notifiers} && \
    mkdir -p /etc/grafana/dashboards/user && \
    chown -R grafana:grafana /etc/grafana

# Copy configuration files
COPY conf/grafana.ini /etc/grafana/grafana.ini
COPY conf/provisioning/dashboards/*.yaml /etc/grafana/provisioning/dashboards/
COPY conf/provisioning/datasources/*.yaml /etc/grafana/provisioning/datasources/
COPY conf/dashboards/user/*.json /etc/grafana/dashboards/user/

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

EXPOSE 3000

USER grafana

CMD ["grafana-server", \
     "--homepath=/usr/share/grafana", \
     "--config=/etc/grafana/grafana.ini", \
     "--packaging=docker"]