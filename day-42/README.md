# Day 42 — Capstone Project: KodeKloud Microservices Voting App

## Overview

This project is the official Kubernetes implementation of the industry-standard **Microservices Example Voting App** (from [kodekloudhub/example-voting-app](https://github.com/kodekloudhub/example-voting-app/tree/master/k8s-specifications)).

It synthesizes everything learned from **Day 01 to Day 41** into an end-to-end, multi-tier cloud-native deployment.

---

## Architecture Diagram

![Kubernetes Voting App Architecture](voting-app-architecture.svg)

```mermaid
flowchart LR
    subgraph External["External World (Users)"]
        Voters["👥 Voters\n(Browser)"]
        Viewers["📊 Viewers\n(Browser)"]
    end

    subgraph K8s["☸️ Kubernetes Cluster"]
        subgraph Frontends["Frontend Services (NodePort)"]
            VoteSVC["Service: vote-service\nType: NodePort (31000)\nPort: 8080 ➔ TargetPort: 80"]
            VotePod["Pod: vote\n(Python Flask)\nTargetPort: 80"]

            ResultSVC["Service: result-service\nType: NodePort (31001)\nPort: 8081 ➔ TargetPort: 80"]
            ResultPod["Pod: result\n(Node.js UI)\nTargetPort: 80"]
        end

        subgraph InQueue["Queue Layer (ClusterIP)"]
            RedisSVC["Service: redis-service\nType: ClusterIP (redis)\nPort: 6379 ➔ TargetPort: 6379"]
            RedisPod["Pod: redis\n(In-Memory Queue)\nVolume: /data"]
        end

        subgraph Processing["Background Worker"]
            WorkerPod["Pod: worker\n(.NET Daemon)\nNo Service Needed"]
        end

        subgraph Database["Persistent Database Layer (ClusterIP)"]
            DBSVC["Service: db-service\nType: ClusterIP (db)\nPort: 5432 ➔ TargetPort: 5432"]
            DBPod["Pod: db\n(PostgreSQL 15)\nVolume: /var/lib/.../data"]
        end
    end

    Voters -->|http://node-ip:31000| VoteSVC --> VotePod
    VotePod -->|writes votes to redis:6379| RedisSVC --> RedisPod
    WorkerPod -->|pulls votes from redis:6379| RedisSVC
    WorkerPod -->|writes aggregated votes to db:5432| DBSVC --> DBPod
    ResultPod -->|reads tallies from db:5432| DBSVC
    Viewers -->|http://node-ip:31001| ResultSVC --> ResultPod

    classDef k8s fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
    classDef svc fill:#1e1b4b,stroke:#818cf8,stroke-width:1.5px,color:#c7d2fe;
    classDef redis fill:#450a0a,stroke:#ef4444,stroke-width:2px,color:#fecaca;
    classDef db fill:#082f49,stroke:#0ea5e9,stroke-width:2px,color:#bae6fd;
    classDef worker fill:#3b0764,stroke:#a855f7,stroke-width:2px,color:#e9d5ff;
    classDef node fill:#064e3b,stroke:#10b981,stroke-width:2px,color:#a7f3d0;

    class VotePod k8s;
    class VoteSVC,ResultSVC svc;
    class RedisPod,RedisSVC redis;
    class WorkerPod worker;
    class DBPod,DBSVC db;
    class ResultPod node;
```

---

## 5-Step Implementation Guide

Deploy the system in order of internal dependencies: Data layers first, workers second, and external frontends last.

---

### Step 1: In-Memory Queue (Redis)
Redis holds raw incoming votes in RAM so the database is never overwhelmed by sudden traffic spikes.

* **Deployment (`redis-deployment.yaml`):**
  * Image: `redis:alpine`
  * Container Port: `6379`
  * Volume: `emptyDir: {}` mounted at `/data`
* **Service (`redis-service.yaml`):**
  * Type: `ClusterIP` (Internal only)
  * Service Name: `redis` (must match name so `vote` can discover it via CoreDNS)
  * Port: `6379` ➔ TargetPort: `6379`

```bash
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
```

---

### Step 2: Relational Database (PostgreSQL)
PostgreSQL permanently stores the aggregated vote count.

* **Deployment (`db-deployment.yaml`):**
  * Image: `postgres:15-alpine`
  * Container Port: `5432`
  * Environment: `POSTGRES_USER=postgres`, `POSTGRES_PASSWORD=postgres`
  * Volume: `emptyDir: {}` mounted at `/var/lib/postgresql/data`
* **Service (`db-service.yaml`):**
  * Type: `ClusterIP` (Internal only)
  * Service Name: `db` (critical: `worker` and `result` connect to host `db`)
  * Port: `5432` ➔ TargetPort: `5432`

```bash
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml
```

---

### Step 3: Background Worker (.NET)
The worker consumes votes from Redis, processes them, and writes the tallies into PostgreSQL.

* **Deployment (`worker-deployment.yaml`):**
  * Image: `dockersamples/examplevotingapp_worker`
  * Label: `app: worker`
* **Service:**
  * **None needed!** The worker acts purely as a client — it makes outgoing connections to `redis` and `db`. Nothing calls the worker directly.

```bash
kubectl apply -f worker-deployment.yaml
```

---

### Step 4: Voting App (Python Frontend)
The public-facing web UI where users choose between Cats and Dogs.

* **Deployment (`vote-deployment.yaml`):**
  * Image: `dockersamples/examplevotingapp_vote`
  * Container Port: `80` (Python Flask listens on port 80)
* **Service (`vote-service.yaml`):**
  * Type: `NodePort`
  * NodePort: `31000` (User browser port)
  * Port: `8080` (Service port)
  * TargetPort: `80` (Container port)

```bash
kubectl apply -f vote-deployment.yaml
kubectl apply -f vote-service.yaml
```

---

### Step 5: Result App (Node.js Frontend)
The public-facing analytics UI showing real-time vote percentages.

* **Deployment (`result-deployment.yaml`):**
  * Image: `dockersamples/examplevotingapp_result`
  * Container Port: `80`
* **Service (`result-service.yaml`):**
  * Type: `NodePort`
  * NodePort: `31001` (User browser port)
  * Port: `8081` (Service port)
  * TargetPort: `80` (Container port)

```bash
kubectl apply -f result-deployment.yaml
kubectl apply -f result-service.yaml
```

---

## One-Click Deployment Script

To deploy and verify all 5 microservices automatically:

```bash
cd day-42
chmod +x demo.sh
./demo.sh
```

---

## Port Mapping Reference

| Microservice | Internal Container Port (`targetPort`) | Service Port (`port`) | Node Port (`nodePort`) | Access URL |
| :--- | :--- | :--- | :--- | :--- |
| **`vote`** | `80` | `8080` | **`31000`** | `http://<NODE-IP>:31000` |
| **`result`** | `80` | `8081` | **`31001`** | `http://<NODE-IP>:31001` |
| **`redis`** | `6379` | `6379` | *None (ClusterIP)* | `redis:6379` (Internal) |
| **`db`** | `5432` | `5432` | *None (ClusterIP)* | `db:5432` (Internal) |
| **`worker`** | *N/A* | *N/A* | *None* | *Background worker* |

---

## Clean Up

To delete all resources created in this project:

```bash
kubectl delete -f vote-service.yaml,vote-deployment.yaml
kubectl delete -f result-service.yaml,result-deployment.yaml
kubectl delete -f worker-deployment.yaml
kubectl delete -f redis-service.yaml,redis-deployment.yaml
kubectl delete -f db-service.yaml,db-deployment.yaml
```

---

## Files in this Directory

- `voting-app-architecture.svg` — Vector architecture diagram
- `redis-deployment.yaml` — Redis queue Deployment
- `redis-service.yaml` — Redis ClusterIP Service
- `db-deployment.yaml` — PostgreSQL database Deployment
- `db-service.yaml` — PostgreSQL ClusterIP Service (`db`)
- `worker-deployment.yaml` — .NET background processing worker Deployment
- `vote-deployment.yaml` — Python voting web app Deployment
- `vote-service.yaml` — Python voting NodePort Service (`31000`)
- `result-deployment.yaml` — Node.js results dashboard Deployment
- `result-service.yaml` — Node.js results NodePort Service (`31001`)
- `demo.sh` — Automated deployment and verification bash script
