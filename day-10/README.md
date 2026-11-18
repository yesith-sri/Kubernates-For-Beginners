# Day 10 — LimitRange and ResourceQuota

## Learning Goal

Apply namespace-wide guardrails so one workload cannot consume all cluster resources.

## Three Layers of Resource Control

Kubernetes can manage resources at several levels:

1. A workload author defines requests and limits on each container.
2. A `LimitRange` applies defaults and allowed boundaries within a namespace.
3. A `ResourceQuota` caps the namespace's total requested resources, limits, and object counts.

These controls complement each other rather than replace one another.

## LimitRange

This lesson's `LimitRange` targets containers. If a new container omits resource values, Kubernetes supplies these defaults:

- Request: `100m` CPU and `64Mi` memory
- Limit: `200m` CPU and `128Mi` memory

The defaults are applied during admission when the Pod is created. A LimitRange can also define minimum and maximum values, although this example only provides defaults.

## ResourceQuota

The `ResourceQuota` creates one shared budget for the current namespace:

- Total CPU requests: `1` core
- Total CPU limits: `2` cores
- Total memory requests: `512Mi`
- Total memory limits: `1Gi`
- Maximum Pods: `5`

If a new object would exceed a hard quota, the Kubernetes API rejects it. The quota does not automatically distribute resources equally between Pods.

## Run the Demo

```bash
kubectl apply -f limitrange.yaml
kubectl apply -f resourcequota.yaml
```

Inspect the effective rules and current usage:

```bash
kubectl describe limitrange my-limitrange
kubectl describe resourcequota my-quota
```

The quota output shows `Used` and `Hard` values. Both objects apply only to the namespace in which you create them.

## How the Two Work Together

When a Pod omits resources, the LimitRange can first add default requests and limits. Those values then count against the ResourceQuota. If the resulting totals exceed the namespace budget, the Pod is rejected.

## Common Beginner Mistakes

- Applying policies in the wrong namespace
- Assuming ResourceQuota changes existing Pods automatically
- Setting a quota for requests or limits without ensuring workloads provide those values or receive LimitRange defaults
- Choosing defaults that make the namespace quota too easy to exhaust

## Key Takeaway

LimitRange controls defaults and boundaries for individual containers. ResourceQuota controls combined usage across an entire namespace.

## Interview Question

**What is the difference between LimitRange and ResourceQuota?**

LimitRange governs resource settings for individual objects in one namespace. ResourceQuota restricts the namespace's total resource consumption and object counts.

## Clean Up

```bash
kubectl delete -f resourcequota.yaml
kubectl delete -f limitrange.yaml
```

## Lesson Files

- `demo.sh` — creates and inspects both namespace policies
- `limitrange.yaml` — supplies default container requests and limits
- `resourcequota.yaml` — defines the total namespace budget
