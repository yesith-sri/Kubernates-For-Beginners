# Day 07 — Secrets: Handling Sensitive Data

## Learning Goal

Store and provide passwords, tokens, and keys without placing them directly in an application image or ConfigMap.

## What Is a Secret?

A Kubernetes Secret is an object designed to hold sensitive values. Pods can consume Secret data as environment variables or mounted files. Kubernetes decodes the selected value before providing it to the container.

This lesson uses an `Opaque` Secret, the general-purpose type for user-defined key-value data.

## Base64 Is Not Encryption

Values under the manifest's `data` field are Base64 encoded. Base64 only changes the representation of data; anyone can decode it. It does not protect the value like encryption.

For a production cluster, use least-privilege RBAC, enable encryption at rest for Secret data in etcd, avoid committing real secrets to Git, and consider an external secret manager.

## What This Lesson Creates

`secret.yaml` defines `DB_PASSWORD` and `API_KEY`. Generate a Base64 value with:

```bash
echo -n 'my-password' | base64
```

The `-n` option prevents a newline from becoming part of the encoded value.

`secret-pod.yaml` uses `secretKeyRef` to inject both values as environment variables. The application receives the decoded text rather than the Base64 representation.

## Run the Demo

```bash
kubectl apply -f secret.yaml
kubectl apply -f secret-pod.yaml
kubectl get pods
```

Verify the lesson value:

```bash
kubectl exec -it my-secret-pod -- printenv DB_PASSWORD
```

This command prints a secret to the terminal and is included only for learning. Avoid exposing production secrets through logs, screenshots, shell history, or debugging output.

## ConfigMap vs Secret

- Use a **ConfigMap** for non-sensitive application settings.
- Use a **Secret** for passwords, tokens, certificates, and private keys.
- Both can be exposed as environment variables or mounted files, but Secrets require stronger access controls and operational care.

## Key Takeaway

Secrets separate sensitive values from application images, but secure usage still requires RBAC, encryption at rest, and careful handling.

## Interview Question

**Are Kubernetes Secrets encrypted by default?**

Secret values in YAML are Base64 encoded, not encrypted. Encryption at rest for etcd must be configured by the cluster operator, while RBAC controls who can read the Secret through the API.

## Clean Up

```bash
kubectl delete -f secret-pod.yaml
kubectl delete -f secret.yaml
```

## Lesson Files

- `demo.sh` — encodes a sample value, creates the resources, and verifies injection
- `secret.yaml` — sample encoded credentials for local learning only
- `secret-pod.yaml` — injects Secret keys as environment variables
