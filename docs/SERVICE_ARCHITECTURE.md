# Service Architecture

## Service Naming Convention and Implementation

This project uses purpose-based naming for services rather than implementation-specific names. This approach ensures:

- Clear architectural understanding
- Implementation flexibility
- Consistent naming conventions
- Better documentation
- Easier onboarding for new team members
- Ability to switch technologies seamlessly without being tied to the previous software's name

## Service Directory

Below is a mapping of purpose-based names to their current implementations:

| Purpose-Based Name | Implementation | Description                               |
| ------------------ | -------------- | ----------------------------------------- |
| service-registry   | Consul         | Service discovery and health checking     |
| secret-manager     | Vault          | Secrets management and encryption         |
| data-store         | PostgreSQL     | Primary data storage and persistence      |
| cache-store        | Redis          | High-performance data caching             |
| message-queue      | RabbitMQ       | Asynchronous message processing           |
| load-balancer      | HAProxy/NGINX  | Traffic distribution and load balancing   |
| search-engine      | Meilisearch    | Full-text search capabilities             |
| metrics-collector  | Prometheus     | System and application metrics collection |
| metrics-visualizer | Grafana        | Metrics visualization and dashboards      |
| log-store          | Elasticsearch  | Centralized log storage and analysis      |
| log-collector      | Fluent Bit     | Log collection and forwarding             |

## Service Locations

Services are organized in the following directory structure:

```plaintext
docker/
├── service-registry/      # Service discovery (Consul)
├── secret-manager/        # Secrets management (Vault)
├── data-store/            # Data persistence (PostgreSQL)
├── cache-store/           # Caching layer (Redis)
├── message-queue/         # Message broker (RabbitMQ)
├── load-balancer/         # Load balancing (HAProxy/NGINX)
├── search-engine/         # Search services (Meilisearch)
├── metrics-collector/     # Metrics collection (Prometheus)
├── metrics-visualizer/    # Metrics visualization (Grafana)
├── log-store/             # Log storage (Elasticsearch)
└── log-collector/         # Log collection (Fluent Bit)
```
