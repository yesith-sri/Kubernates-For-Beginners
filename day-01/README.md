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

## Under the Hood: The Pause Container (Pod Sandbox)

When Kubernetes creates a Pod, it does not start your application container first. Instead, it starts a hidden infrastructure container known as the **Pause Container** (also called the Sandbox container).

- **Who holds the Pod IP?**
  The pause container creates and holds the Linux Network Namespace, network interfaces, and the assigned Pod IP.
- **Why containers in a Pod share localhost:**
  All user containers in the Pod join the pause container's network namespace (`--net=container:<pause-id>`). This is why they share the same IP address and can communicate seamlessly over `localhost`.
- **Why Pod IP survives application crashes:**
  If your application container crashes or restarts, only that application container terminates. The pause container stays running on the node, keeping the network namespace and Pod IP intact without changing.
- **Inspecting the Pause Container on the Worker Node:**
  It is hidden from `kubectl get pods`, but running on the worker node. You can inspect it via SSH or node terminal:
  ```bash
  # For containerd / CRI-O (modern Kubernetes):
  crictl ps | grep pause

  # For Docker runtime:
  docker ps | grep pause
  ```

## Common Beginner Mistake

Do not treat a standalone Pod as a production deployment. A bare Pod is useful for learning, testing, and debugging, but a Deployment is normally used to recreate failed Pods automatically.

## Key Takeaway

Kubernetes manages **Pods**, and Pods run **containers**.

## Interview Question

**What is the smallest deployable unit in Kubernetes?**

A Pod. It wraps one or more containers and provides shared networking, storage, and lifecycle management.

**Bonus Interview Question: What is the pause container in Kubernetes?**

The pause container (or sandbox container) is an infrastructure container that runs first in every Pod. It creates and holds the network namespace (Pod IP and interfaces) and IPC namespace. All containers in the Pod join its network namespace. If an application container crashes and restarts, the Pod IP does not change because the pause container remains alive.

## Clean Up

```bash
kubectl delete pod my-pod
```

## Lesson Files

- `demo.sh` — commands that create and inspect the Pod
- `pod.yaml` — a declarative NGINX Pod manifest for comparison
