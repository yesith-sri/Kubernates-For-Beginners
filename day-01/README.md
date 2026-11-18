# Day 01 — What Is a Pod and Why Does It Exist?

## Learning Goal

Understand the basic unit that Kubernetes creates, schedules, and manages.

## What Is a Pod?

A **Pod** is the smallest deployable unit in Kubernetes. Kubernetes does not place a container directly on a worker node. Instead, it places the container inside a Pod and schedules that Pod onto a node.

Think of a Pod as a small wrapper around one or more closely related containers. The Pod provides them with:

- One shared IP address
- One shared network namespace
- Optional shared storage volumes
- A common lifecycle and location on the same node

Most Pods contain one main application container. A Pod can contain multiple containers when those containers must work closely together.

## How This Lesson Works

The demo creates a Pod named `my-pod` with the NGINX image:

```bash
kubectl run my-pod --image=nginx --restart=Never
```

`--restart=Never` tells `kubectl` to create a standalone Pod instead of another workload type. Kubernetes then selects a node, downloads the NGINX image, starts the container, and gives the Pod an IP address.

Check its status:

```bash
kubectl get pods
```

When the `STATUS` becomes `Running` and `READY` shows `1/1`, the container is ready. View detailed information with:

```bash
kubectl describe pod my-pod
```

Look for the assigned node, Pod IP, container image, current state, and recent events.

## Important Mental Model

The container runs your application, while the Pod is the Kubernetes object that manages the container. If the Pod is deleted, its containers disappear with it. A newly created replacement Pod may receive a different IP address.

## Common Beginner Mistake

Do not treat a standalone Pod as a production deployment. A bare Pod is useful for learning, testing, and debugging, but a Deployment is normally used to recreate failed Pods automatically.

## Key Takeaway

Kubernetes manages **Pods**, and Pods run **containers**.

## Interview Question

**What is the smallest deployable unit in Kubernetes?**

A Pod. It wraps one or more containers and provides shared networking, storage, and lifecycle management.

## Clean Up

```bash
kubectl delete pod my-pod
```

## Lesson Files

- `demo.sh` — commands that create and inspect the Pod
- `pod.yaml` — a declarative NGINX Pod manifest for comparison
