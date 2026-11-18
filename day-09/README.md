# Day 09 — Resource Requests and Limits

## Learning Goal

Tell Kubernetes how much CPU and memory a container needs and control how much it may consume.

## Requests: The Scheduling Promise

A resource request describes the amount Kubernetes should reserve when deciding where to place a Pod. The scheduler selects a node with enough unallocated requested capacity.

In this lesson, the container requests:

- `250m` CPU, equal to one quarter of a CPU core
- `64Mi` memory

A request is not necessarily the most the container can use. If spare resources exist, it can use more until it reaches a configured limit.

## Limits: The Runtime Boundary

A limit controls maximum resource usage:

- When a container reaches its CPU limit, Linux throttles its CPU time. The container normally keeps running but may become slower.
- When a container exceeds its memory limit, it can be terminated with an `OOMKilled` reason and then restarted according to the Pod policy.

This lesson limits the container to `500m` CPU and `128Mi` memory.

## Run the Demo

```bash
kubectl apply -f resource-pod.yaml
kubectl get pods
kubectl describe pod my-resource-pod
```

In the description, find the `Requests`, `Limits`, and `QoS Class` sections.

## Quality of Service Classes

- **Guaranteed** — every container has CPU and memory requests equal to its limits.
- **Burstable** — at least one request or limit exists, but the Pod does not meet all Guaranteed requirements.
- **BestEffort** — no container defines CPU or memory requests or limits.

This lesson's Pod is **Burstable** because its requests are lower than its limits. Under node memory pressure, QoS class influences which Pods Kubernetes considers for eviction.

## Choosing Values

Start from observed application usage rather than guessing. Set requests near normal requirements and limits with enough headroom for valid peaks. Limits that are too low cause throttling or restarts; requests that are too high waste schedulable capacity.

## Key Takeaway

Requests guide scheduling and capacity planning. Limits enforce runtime boundaries.

## Interview Question

**What happens when CPU or memory exceeds a limit?**

CPU is throttled. Excess memory can cause the container to be OOM-killed. The scheduler uses requests—not current live usage—to place the Pod.

## Clean Up

```bash
kubectl delete -f resource-pod.yaml
```

## Lesson Files

- `demo.sh` — creates the Pod and shows its resource configuration
- `resource-pod.yaml` — defines CPU and memory requests and limits
