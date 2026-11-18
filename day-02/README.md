# Day 02 — Writing Your First Pod YAML

## Learning Goal

Learn how to describe a Kubernetes object in a YAML manifest and create it declaratively.

## Imperative vs Declarative Management

On Day 01, `kubectl run` created a Pod using a command. That is the **imperative** approach: you tell Kubernetes what to do immediately.

Today you use the **declarative** approach. You write the desired state in a YAML file and ask Kubernetes to make the cluster match it. YAML files can be reviewed, stored in Git, reused, and applied consistently.

## The Four Main Sections

- `apiVersion` selects the Kubernetes API version. A Pod is a core resource, so it uses `v1`.
- `kind` identifies the object type. This manifest creates a `Pod`.
- `metadata` gives the object an identity, including its name and labels.
- `spec` describes the desired state, including the containers that should run.

Inside `spec.containers`, this lesson defines:

- `name: nginx-container` — the container's name inside the Pod
- `image: nginx` — the container image Kubernetes should pull and run
- `containerPort: 80` — documentation that NGINX listens on port 80; it does not expose the Pod outside the cluster by itself

The label `app: my-app` is a searchable tag. Later, Services and other resources can use label selectors to find matching Pods.

## Run the Lesson

Read the manifest before applying it:

```bash
cat pod.yaml
```

Create or update the declared object:

```bash
kubectl apply -f pod.yaml
```

Verify the result:

```bash
kubectl get pods
kubectl get pod my-pod -o yaml
```

`kubectl apply` is repeatable. If the object already matches the file, Kubernetes reports it as unchanged.

## Common Beginner Mistakes

- YAML indentation matters; use spaces instead of tabs.
- Resource names must be valid DNS-style names, usually lowercase with hyphens.
- `containerPort` does not create a Service or make the application publicly accessible.
- If Day 01's Pod still exists with a different immutable specification, delete it before applying this manifest.

## Key Takeaway

A manifest records the desired state. Kubernetes continuously stores and manages that desired state after you apply it.

## Interview Question

**What are the main top-level fields in a Kubernetes manifest?**

They are `apiVersion`, `kind`, `metadata`, and `spec`. Some resources also expose a `status` field, which Kubernetes manages rather than the user.

## Clean Up

```bash
kubectl delete -f pod.yaml
```

## Lesson Files

- `demo.sh` — commands to inspect, apply, and verify the manifest
- `pod.yaml` — a commented NGINX Pod manifest
