# Day 05 — Sidecar Containers

## Learning Goal

Use a helper container that runs beside the main application for the entire Pod lifetime.

## What Is a Sidecar?

A sidecar is a container that adds a supporting capability to the main application without changing the application's code. The containers live in the same Pod, share the Pod network, and can mount the same volumes.

Common sidecar responsibilities include log collection, proxying, certificate renewal, file synchronization, and configuration refresh.

## What This Manifest Does

This Pod contains two long-running containers:

- `nginx-container` represents the main application and mounts `config-vol` at `/etc/config`.
- `config-refresher` writes the current timestamp to `/etc/config/app.properties` every ten seconds.

Both containers mount the same `emptyDir` volume. A file written by the sidecar therefore becomes visible to NGINX immediately through the shared volume.

## Run the Demo

```bash
kubectl apply -f sidecar-pod.yaml
kubectl get pods
```

The Pod should show `2/2` ready containers. Read the generated file from the main container:

```bash
kubectl exec -it my-sidecar-pod -c nginx-container -- cat /etc/config/app.properties
```

Run the command again after ten seconds. The timestamp should change even though the NGINX container was not restarted.

## Sidecar vs Init Container

- An **init container** runs first, completes, and exits before the application starts.
- A **sidecar** keeps running alongside the application and continuously supports it.

## Important Detail

The file changes without a restart, but a real application must be designed to reread or watch that file. Some applications load configuration only during startup and would still require a reload signal or restart.

## Key Takeaway

A sidecar extends the main application through shared networking or storage while keeping responsibilities in separate containers.

## Interview Question

**When should two containers run in the same Pod?**

When they are tightly coupled, share resources such as a volume or local network, and should be scheduled and managed as one unit.

## Clean Up

```bash
kubectl delete -f sidecar-pod.yaml
```

## Lesson Files

- `demo.sh` — commands to observe the shared file changing
- `sidecar-pod.yaml` — NGINX and a configuration refresher sidecar
