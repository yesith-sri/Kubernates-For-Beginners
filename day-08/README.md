# Day 08 — ConfigMaps as Environment Variables vs Volume Mounts

## Learning Goal

Choose the right way to provide ConfigMap data to an application.

## Two Common Injection Methods

### Environment variables

Each ConfigMap value becomes a variable in the container process. This is simple for applications that already read environment variables. The values are fixed when the container starts, so a running container does not receive later ConfigMap changes.

### Volume-mounted files

Kubernetes creates one file per ConfigMap key inside the mount directory. The filename is the key and the file content is the value. Kubernetes periodically updates projected files after the ConfigMap changes, although the update is not immediate.

The application must reread or watch the file to use the new content. Mounts that use `subPath` do not receive automatic ConfigMap updates.

## What This Manifest Does

The Pod defines a volume named `config-vol` whose source is `my-config`. It mounts that volume at `/etc/config` inside the NGINX container.

Kubernetes creates these files:

```text
/etc/config/APP_NAME
/etc/config/APP_ENV
/etc/config/DB_URL
```

## Run the Demo

```bash
kubectl apply -f configmap.yaml
kubectl apply -f configmap-volume-pod.yaml
kubectl get pods
```

List and read the projected files:

```bash
kubectl exec -it my-configmap-vol-pod -- ls /etc/config
kubectl exec -it my-configmap-vol-pod -- cat /etc/config/APP_NAME
kubectl exec -it my-configmap-vol-pod -- cat /etc/config/APP_ENV
```

## How to Choose

- Choose environment variables when the application expects them and configuration changes require a controlled restart.
- Choose mounted files when the application can reload configuration from files and live updates are useful.
- Use a Secret instead when the data is sensitive.

## Common Beginner Mistake

An updated mounted file does not guarantee that the application has reloaded it. Kubernetes updates the file, but the application is responsible for detecting and applying the new value.

## Key Takeaway

Environment variables are a startup snapshot; mounted ConfigMap files can be refreshed while the Pod is running.

## Interview Question

**Does a Pod automatically use an updated ConfigMap?**

Environment variables do not update without recreating the container. Volume-mounted files are eventually refreshed, but the application must reread them, and `subPath` mounts are not refreshed.

## Clean Up

```bash
kubectl delete -f configmap-volume-pod.yaml
kubectl delete -f configmap.yaml
```

## Lesson Files

- `demo.sh` — creates the ConfigMap and reads its mounted files
- `configmap.yaml` — the source key-value configuration
- `configmap-volume-pod.yaml` — projects the ConfigMap into `/etc/config`
