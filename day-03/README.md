# Day 03 — Multi-Container Pods

## Learning Goal

Understand when multiple containers belong in one Pod and how they communicate.

## How Multi-Container Pods Work

A Pod can run more than one container. Every container in that Pod is scheduled onto the same node and shares the Pod's network namespace. This means the containers share one Pod IP and can reach each other through `localhost` on different ports.

Containers can also share data by mounting the same volume. They still have separate container images and filesystems unless a shared volume is configured.

Use one Pod only when the containers are tightly coupled and should be created, moved, and deleted together. Independent applications should normally run in separate Pods so they can scale and fail independently.

## What This Manifest Creates

The lesson creates one Pod named `my-pod` with two containers:

- `nginx-container` runs NGINX on port 80.
- `busybox-container` stays alive with `sleep 3600` and acts as a test client.

After applying the manifest, the `READY` column should show `2/2`:

```bash
kubectl apply -f multi-container-pod.yaml
kubectl get pods
```

The following command runs `wget` inside BusyBox and connects to NGINX through `localhost`:

```bash
kubectl exec -it my-pod -c busybox-container -- wget -qO- localhost
```

The `-c` option is required because the Pod has multiple containers and `kubectl` must know which one should execute the command.

## Common Multi-Container Patterns

- **Sidecar** — supports the main application, such as a log shipper or configuration refresher.
- **Ambassador** — proxies communication between the application and an external service.
- **Adapter** — transforms the main application's output into another format.

These are design patterns, not separate Kubernetes resource types.

## Common Beginner Mistakes

- Do not put unrelated applications into one Pod.
- Two containers in one Pod cannot bind to the same port because they share a network namespace.
- If a short-lived container finishes, the Pod may show fewer ready containers even if another container is running.

## Key Takeaway

Containers in the same Pod share networking and communicate through `localhost`, but they should be grouped only when their lifecycles are closely related.

## Interview Question

**How do containers inside the same Pod communicate?**

They use `localhost` because they share the same network namespace and Pod IP. They can share files only when they mount a shared volume.

## Clean Up

```bash
kubectl delete -f multi-container-pod.yaml
```

## Lesson Files

- `demo.sh` — commands to create and test the two-container Pod
- `multi-container-pod.yaml` — NGINX and BusyBox in one Pod
