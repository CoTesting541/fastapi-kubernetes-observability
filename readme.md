# Kubernetes-Based FastAPI Platform with Centralized Logging

A cloud-native backend platform built around a FastAPI service running on Kubernetes with PostgreSQL for persistence, Redis for caching, and centralized log aggregation using Grafana Loki, Alloy, and Grafana.

The project focuses on practical backend and platform engineering concepts:

* deploying services to Kubernetes
* separating application, data, and monitoring concerns across namespaces
* integrating caching and persistent storage
* collecting and querying logs across distributed workloads
* debugging and operating services in a containerized environment

---

## Architecture

The platform is split into three logical areas:

### Application Layer

* **FastAPI** service (`user-service`)
* REST API endpoints for user operations
* Logging added for observability

### Data Layer

* **PostgreSQL** for persistent storage
* **Redis** for caching 

### Observability Layer

* **Grafana Loki** for log aggregation
* **Grafana Alloy** for Kubernetes log collection and metadata enrichment
* **Grafana** for querying and visualizing logs
* **MinIO** used as object storage backend for Loki

---

## Tech Stack

| Component            | Purpose                        |
| -------------------- | ------------------------------ |
| FastAPI              | Backend API                    |
| PostgreSQL           | Persistent relational database |
| Redis                | Cache layer                    |
| Kubernetes (k3d/k3s) | Container orchestration        |
| Docker               | Containerization               |
| Helm                 | Kubernetes package management  |
| Grafana Loki         | Log aggregation                |
| Grafana Alloy        | Log collection                 |
| Grafana              | Log exploration and dashboards |
| MinIO                | Loki object storage            |

---

## Kubernetes Layout

The project is organized into namespaces to separate the layers:

* `dev` → application services
* `data` → PostgreSQL and Redis
* `monitoring` → Grafana, Loki, Alloy, and monitoring components

Example workloads:

```text
monitoring/
├── grafana
├── loki-write
├── loki-read
├── loki-backend
├── alloy
└── minio

data/
├── postgres
└── redis

dev/
└── user-service
```

---

## Features

### Centralized Logging

* Logs collected from Kubernetes pods using Alloy
* Kubernetes metadata attached to logs:

  * namespace
  * pod
  * container
  * application labels
* Logs aggregated into Loki
* Searchable in Grafana Explore

### Multi-Namespace Observability

* Logs collected across:

  * `dev`
  * `data`
  * `monitoring`
* Supports troubleshooting of both application and infrastructure components

---

## Example Workflow

1. A request reaches the FastAPI service
2. The service queries Redis for cached data
3. On cache miss, PostgreSQL is queried
4. Application logs are generated
5. Alloy collects logs from Kubernetes pods
6. Loki indexes logs
7. Grafana is used to query and inspect service behavior

---

## Running the Project

### Deploy to Kubernetes

Install components using Helm manifests and Kubernetes resources.
rollout_app.ps1 and rollout_monitor.ps1 shell scripts added for easier deployment.
Grafana need configuring when adding Loki as datasource, specially the url and http header/value

## Project Goals

This project was built to practice:

* backend development with FastAPI
* containerization with Docker
* Kubernetes deployments and troubleshooting
* stateful services in Kubernetes
* caching strategies using Redis
* centralized logging and observability
* debugging distributed systems

---

## Future Improvements

Potential next steps:

* Prometheus metrics integration
* request tracing with OpenTelemetry
* Grafana dashboards for service metrics
* CI/CD pipeline for automated deployments
* authentication and authorization

---

## Reliability scenarios tested

Trying to simulate SRE work environment by doing a few reliablity testing

### Pod crash recovery

* Simulated pod termination in Kubernetes
* Verified automatic restart via Deployment controller
* Confirmed service continuity after rescheduling

### Database restart recovery

* Restarted PostgreSQL pod
* Verified application reconnection behavior
* Confirmed no data loss for persisted records

### Log spike handling

* Generated high request volume to FastAPI service
* Verified log ingestion in Loki without pipeline failure
* Validated query responsiveness in Grafana during increased load

### Latency simulation

* Introduced artificial delays in API responses
* Observed request behavior in logs via Grafana Explore
* Confirmed visibility of degraded response times

### Resource pressure / throttling

* Applied CPU/memory limits to pods
* Observed Kubernetes scheduling and throttling behavior
* Verified system stability under constrained resources

---

## License

For learning and portfolio purposes.
