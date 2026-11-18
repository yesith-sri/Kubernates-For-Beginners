# Day 06 — ConfigMaps: Externalizing Configuration

## Learning Goal

Separate non-sensitive application configuration from the container image.

## Why ConfigMaps Exist

Applications often need values that change between environments, such as an application name, feature setting, or database URL. Baking those values into an image would require a new image for every configuration change.

A ConfigMap stores non-sensitive configuration in Kubernetes as key-value pairs. The same application image can then receive different configuration in development, testing, and production.

Do not use a ConfigMap for passwords, tokens, or private keys. Those values belong in a Secret.

## What This Lesson Creates

`configmap.yaml` creates a ConfigMap named `my-config` with three keys:

- `APP_NAME` identifies the application.
- `APP_ENV` identifies the environment.
- `DB_URL` contains a database connection location.

`configmap-pod.yaml` reads each key with `configMapKeyRef` and creates matching environment variables inside the NGINX container.

The ConfigMap must exist before the Pod can start successfully because the references are required by default.

## Run the Demo

```bash
kubectl apply -f configmap.yaml
kubectl apply -f configmap-pod.yaml
kubectl get pods
```

Inspect the ConfigMap and verify the injected values:

```bash
kubectl describe configmap my-config
kubectl exec -it my-configmap-pod -- env | grep APP
kubectl exec -it my-configmap-pod -- printenv DB_URL
```

## Important Update Behavior

Environment variables are copied into the container when it starts. Editing the ConfigMap does not change environment variables inside an already running container. Recreate or restart the Pod to receive new values.

## Common Beginner Mistakes

- Creating the Pod before its required ConfigMap exists
- Misspelling the ConfigMap name or key
- Storing sensitive credentials in a ConfigMap
- Expecting environment variables to update while the container is running

## Key Takeaway

ConfigMaps keep non-sensitive configuration outside the image and inject it at runtime.

## Interview Question

**How can a Pod consume a ConfigMap?**

It can use individual environment variables, import all keys with `envFrom`, mount the ConfigMap as files in a volume, or read it through the Kubernetes API.

## Clean Up

```bash
kubectl delete -f configmap-pod.yaml
kubectl delete -f configmap.yaml
```

## Lesson Files

- `demo.sh` — creates the resources and verifies environment variables
- `configmap.yaml` — non-sensitive application configuration
- `configmap-pod.yaml` — injects individual ConfigMap keys as environment variables
