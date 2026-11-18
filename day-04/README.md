# Day 04 — Init Containers

## Learning Goal

Run required setup work before the main application container starts.

## What Is an Init Container?

An init container is a special container that runs before the regular application containers in a Pod. It must finish successfully before Kubernetes starts the main application.

When a Pod has multiple init containers, Kubernetes runs them sequentially in the order defined. If one fails, Kubernetes retries it according to the Pod restart policy. The application remains blocked until every init container succeeds.

This separation keeps setup tools and logic out of the main application image.

## What This Manifest Does

The Pod defines an `emptyDir` volume named `config-vol`. The volume is created for the Pod and is accessible to both containers.

The `init-downloader` container runs first. It downloads a file from GitHub and writes it to `/etc/config/app.properties` on the shared volume. After that command exits successfully, the init container is complete.

Only then does `nginx-container` start. It mounts the same volume at `/etc/config`, so it can read the file prepared by the init container.

## Run and Observe

```bash
kubectl apply -f init-container-pod.yaml
kubectl get pods --watch
```

You may briefly see `Init:0/1`, followed by `PodInitializing`, and finally `Running`. If the download cannot complete, inspect the init container:

```bash
kubectl describe pod my-init-pod
kubectl logs my-init-pod -c init-downloader
```

This lesson requires internet access from the cluster because the init container downloads a remote file.

## Good Use Cases

- Wait for a dependency such as a database or DNS name
- Download configuration or startup data
- Generate files or adjust permissions on a shared volume
- Run database preparation before the application begins

An init container should finish and exit. A helper that must keep running belongs in a sidecar instead.

## Key Takeaway

Init containers create an ordered startup gate: setup must succeed before the application can run.

## Interview Question

**What happens when an init container fails?**

The main containers do not start. Kubernetes retries the failed init container until it succeeds or the Pod is removed, subject to the Pod's restart policy.

## Clean Up

```bash
kubectl delete -f init-container-pod.yaml
```

## Lesson Files

- `demo.sh` — commands to create and watch the Pod initialize
- `init-container-pod.yaml` — an init container, main container, and shared volume
