# Kubernetes-Based FastAPI Platform with Centralized Logging

This project demonstrates a production-style microservice deployed on Kubernetes with full observability integration. It combines a FastAPI service with PostgreSQL and Redis, instrumented with centralized logging and monitoring to simulate real-world service debugging and reliability workflows.

The goal of this project is to replicate how modern SRE teams observe, debug, and maintain distributed systems in a Kubernetes environment.

---

## Architecture
FastAPI service (stateless API layer)
PostgreSQL (persistent datastore)
Redis (caching layer)
Kubernetes cluster (EKS-compatible)
Grafana stack for observability:
Grafana for visualization
Loki for log aggregation
Grafana Alloy for log/metric shipping

## Observability Design

### Logging
 * Container logs are collected at node level
 * Forwarded via Grafana Alloy
 * Centralized in Loki for structured querying

### Metrics 
* Request latency
* Error rate
* Service availability

## Debug Workflow Simulated
Identify failing endpoint via logs
Correlate with metrics (latency spikes / errors)
Trace container-level issues inside Kubernetes pods

## Biggest Project issues encountered
1. Loki write/read/backend pods trapped in a CrashLoopBackOff state during initialization. | The replication_factor was incorrectly nested under the limit block in the config
2. Alloy agents running error-free but the grafana Explore dropdown was empty | Default config for alloy only included discovery task, no ingestion and write blocks in the config

---

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
* Logging integrated for observability

### Data Layer

* **PostgreSQL** for persistent storage
* **Redis** for caching frequently accessed data

### Observability Layer

* **Grafana Loki** for centralized log aggregation
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

The project is organized into namespaces to separate responsibilities:

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

### FastAPI Service

* REST endpoints for user operations
* Service deployed to Kubernetes
* Containerized using Docker
* Request logging enabled for debugging and monitoring

### PostgreSQL Integration

* Persistent relational storage
* User data stored and queried through the API

### Redis Caching

* Cache layer for repeated requests
* Reduced database lookups for frequently accessed data

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

Typical workflow:

```bash
kubectl apply -f k8s/
helm upgrade --install loki grafana/loki -n monitoring
helm upgrade --install alloy grafana/alloy -n monitoring
```

Check workloads:

```bash
kubectl get pods -A
```

---

## Observability

Example log query in Grafana Explore:

```logql
{namespace="dev"}
```

Filter by:

* namespace
* pod
* container
* application label

---

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

## Deployment
Infrastructure deployed using Kubernetes manifests
Services exposed internally within cluster networking
Observability stack deployed as separate components
(rollout_app.ps1 and rollout_monitor.ps1 added for easier deployment)

## Key Learnings
How distributed logs are used in production debugging
Why centralized observability is critical in microservices
Kubernetes service behavior under failure conditions
How SRE workflows rely on telemetry

## Future Improvements
Add distributed tracing (OpenTelemetry)
Add SLO-based alerting rules in Grafana
Go away from global PostgreSQL database connection to session based
Add Liveness, Readiness and Startup probes
---

## Example Workflow
1. A request reaches the FastAPI service
2. The service queries Redis for cached data
3. On cache miss, PostgreSQL is queried
4. Application logs are generated
5. Alloy collects logs from Kubernetes pods
6. Loki indexes logs
7. Grafana is used to query and inspect service behavior
