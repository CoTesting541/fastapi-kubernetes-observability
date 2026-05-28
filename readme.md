# Kubernetes-Based FastAPI Platform with Centralized Logging

A backend local platform showcasing **FastAPI** service deployed on **Kubernetes**. This project demonstrates practical backend and platform engineering concepts, with **PostgreSQL** for persistence and **Redis** for caching, and a centralized log aggregation stack using Grafana, Loki, Alloy

---

##  Project Overview

The core objective of this project is to practice deploying, operating, and observing distributed systems in a containerized environment. It focuses on:
* Deploying stateful and stateless services to Kubernetes.
* Separating application, data, and monitoring concerns across namespaces.
* Implementing caching strategies to optimize database lookups.
* Collecting, enriching, and querying logs across distributed workloads.

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

##  Architecture & Component Layout

The platform is split into three logical layers across dedicated Kubernetes namespaces to ensure strict separation of concerns.

### 1. Application Layer (`dev`)
* **FastAPI Service (`user-service`)**: REST API endpoints for user operations with logging

### 2. Data Layer (`data`)
* **PostgreSQL**: Persistent database for user data.
* **Redis**: Cache layer to reduce database load.

### 3. Observability Layer (`monitoring`)
* **Loki**: Centralized log aggregation tool.
* **Alloy**: Log collector that scrapes container logs and enriches with k8 metadata.
* **Grafana**: Querying and visualizing logs.
* **MinIO**: Object storage backend used by Loki.

---

##  Tech Stack

| Component | Purpose |
| :--- | :--- |
| **FastAPI** | Backend REST API |
| **PostgreSQL** | Persistent relational storage |
| **Redis** | In-memory cache layer |
| **Kubernetes (k3d/k3s)** | Container orchestration |
| **Docker** | Containerization |
| **Helm** | Kubernetes package management |
| **Grafana Loki** | Log aggregation backend |
| **Grafana Alloy** | Log collection & metadata enrichment |
| **Grafana** | Log exploration & dashboards |
| **MinIO** | S3-compatible storage for Loki |

---

## Example Workflow
1. A request reaches the FastAPI service
2. The service queries Redis for cached data
3. On cache miss, PostgreSQL is queried
4. Application logs are generated
5. Alloy collects logs from Kubernetes pods
6. Loki indexes logs
7. Grafana is used to query and inspect service behavior