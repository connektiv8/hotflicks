# Configuration Guide

## Overview

This guide details the configuration requirements and procedures for each component of the HotFlicks platform. All configurations follow a purpose-based architecture and are stored in `cache/conf/`.

## Architecture Overview

```mermaid
flowchart TB
    subgraph ServiceLayer["Service Layer"]
        direction TB

        subgraph CoreServices["Core Services"]
            sr[service-registry]
            sm[secret-manager]
            lb[load-balancer]
        end

        subgraph DataServices["Data Services"]
            ds[data-store]
            cs[cache-store]
            se[search-engine]
            mq[message-queue]
        end

        subgraph StreamingServices["Streaming Services"]
            es[edge-server]
            vt[video-transcoder]
        end
    end

    subgraph MonitoringLayer["Monitoring Layer"]
        mc[metrics-collector]
        mv[metrics-visualizer]
        ls[log-store]
        lc[log-collector]
    end

    CoreServices --> DataServices
    CoreServices --> StreamingServices
    ServiceLayer --> MonitoringLayer
```

## Service Configuration Locations

Each service's configuration is stored in a dedicated directory under `cache/conf/`:

```plaintext
cache/conf/
├── service-registry/
│   ├── main.conf          # Main configuration
│   ├── client.conf         # Client configuration
│   └── tls/                     # TLS certificates
│
├── secret-manager/
│   ├── main.conf          # Main configuration
│   ├── policies/            # Security policies
│   └── tls/                    # TLS certificates
│
├── data-store/
│   ├── main.conf           # Main configuration
│   ├── replication.conf    # Replication settings
│   └── backup.conf         # Backup configuration
│
├── load-balancer/
│   ├── main.conf           # Main configuration
│   ├── upstream.conf       # Upstream definitions
│   └── ssl/                # SSL certificates
```

## Core Services Configuration

### Service Registry

```mermaid
flowchart LR
    subgraph service-registry["Service Registry"]
        direction TB
        main[main.conf]
        client[client.conf]
        tls[TLS Config]
    end

    subgraph ConfigParams["Configuration Parameters"]
        direction TB
        dc[Datacenter]
        bind[Bind Address]
        peers[Peer List]
        encrypt[Encryption]
    end

    main --> ConfigParams
    client --> ConfigParams
    tls --> encrypt
```

Example configuration:

```ini
# cache/conf/service-registry/main.conf
datacenter = "hotflicks-dc1"
node_name = "registry-1"
data_dir = "/var/lib/service-registry"
client_addr = "0.0.0.0"
ui = true

# TLS Configuration
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
ca_file = "/etc/service-registry/tls/ca.pem"
cert_file = "/etc/service-registry/tls/cert.pem"
key_file = "/etc/service-registry/tls/key.pem"
```

### Secret Manager

```mermaid
flowchart LR
    subgraph secret-manager["Secret Manager"]
        direction TB
        main[main.conf]
        policies[Policies]
        tls[TLS Config]
    end

    subgraph StorageBackend["Storage Backend"]
        direction TB
        db[Database]
        ha[HA Config]
    end

    main --> StorageBackend
    policies --> ha
    tls --> StorageBackend
```

Example configuration:

```ini
# cache/conf/secret-manager/main.conf
storage "data-store" {
    ha_enabled = "true"
    connection_url = "postgres://vault:vault@data-store:5432/vault"
}

listener "tcp" {
    address = "0.0.0.0:8200"
    tls_cert_file = "/etc/secret-manager/tls/cert.pem"
    tls_key_file = "/etc/secret-manager/tls/key.pem"
}
```

## Data Services Configuration

### Data Store

```mermaid
flowchart TB
    subgraph data-store["Data Store Configuration"]
        direction LR
        main[main.conf]
        repl[replication.conf]
        backup[backup.conf]
    end

    subgraph Params["Parameters"]
        perf[Performance]
        ha[High Availability]
        backup_policy[Backup Policy]
    end

    main --> perf
    repl --> ha
    backup --> backup_policy

```

Example configuration:

```ini
# cache/conf/data-store/main.conf
listen_addresses = '*'
max_connections = 1000
shared_buffers = 4GB
work_mem = 64MB
maintenance_work_mem = 512MB
effective_cache_size = 12GB
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
```

## Connection and Security

### TLS Configuration

All services use TLS for secure communication. Certificates are managed by the secret-manager service and stored in respective `tls/` directories.

### Network Policies

Network policies are defined in:

```plaintext
automation/runtime/core/policies/network/
```

## Monitoring Configuration

### Metrics Collection

```mermaid
flowchart LR
    subgraph metrics-collector["Metrics Collection"]
        scrape[Scrape Config]
        rules[Alert Rules]
        storage[Storage Config]
    end

    subgraph Targets["Monitored Targets"]
        services[Services]
        nodes[Nodes]
        custom[Custom Metrics]
    end

    scrape --> Targets
    rules --> alerts[Alert Manager]
```

Example configuration:

```yaml
# cache/conf/metrics-collector/main.conf
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "service-registry"
    static_configs:
      - targets: ["service-registry:8500"]

  - job_name: "data-store"
    static_configs:
      - targets: ["data-store-exporter:9187"]
```

## Additional Configurations

For service-specific detailed configurations, refer to:

- [Service Registry Configuration](service-registry.md)
- [Secret Manager Configuration](secret-manager.md)
- [Data Store Configuration](data-store.md)
- [Load Balancer Configuration](load-balancer.md)
