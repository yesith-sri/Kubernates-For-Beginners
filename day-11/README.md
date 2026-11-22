# Day 11 — Deployments vs ReplicaSets

## Concept
A ReplicaSet ensures a specified number of Pod replicas are running at all times.
A Deployment manages ReplicaSets and handles rolling updates, rollbacks, and self-healing.
Always use Deployments — never create ReplicaSets directly.

## The Self-Healing Mechanism
One of the most powerful features of Kubernetes Deployments is **Self-Healing**:

- **Desired State vs. Actual State:**
  When you declare `replicas: 3` in your Deployment manifest, you define your **Desired State**. The Kubernetes Controller Manager continuously monitors the cluster's **Actual State** via a reconciliation loop.
- **Automatic Pod Recovery:**
  If a Pod crashes, runs out of memory (OOMKilled), or is accidentally deleted by a developer, the ReplicaSet notices:
  `Actual Pods (2) < Desired Pods (3)`
  It instantly creates a brand new replacement Pod without human intervention.
- **Node Failure Recovery:**
  If an entire worker node crashes or loses network connectivity, the control plane detects the node as `NotReady`, marks its Pods for eviction, and the Deployment reschedules replacement Pods onto healthy nodes.

## Key Difference

| | ReplicaSet | Deployment |
|--|-----------|------------|
| Purpose | Maintain Pod count (Self-healing) | Manage ReplicaSets & lifecycle |
| Rolling updates | No | Yes |
| Rollbacks | No | Yes |
| Self-healing | Yes (via pod recreation) | Yes (via managing ReplicaSets) |
| Use directly | Never | Always |

## Key Takeaway
ReplicaSet maintains the count of Pods and provides basic self-healing.
Deployment manages ReplicaSets, handles updates, rollbacks, and provides end-to-end self-healing.
Always use Deployments.

## Interview Questions
**1. What is the difference between a Deployment and a ReplicaSet?**
Answer: ReplicaSet maintains Pod count and replaces crashed or deleted Pods.
Deployment manages ReplicaSets and handles rolling updates, rollbacks, and application lifecycle.

**2. How does the Self-Healing mechanism work in Kubernetes Deployments?**
Answer: Through a continuous reconciliation loop. You define the desired state (e.g., 3 replicas). If a Pod crashes, is killed, or its host node dies, the controller detects that actual state != desired state and automatically creates new replacement Pods to restore the desired count.

## Files
- `demo.sh` — commands to create, verify, and test self-healing on a Deployment
- `deployment.yaml` — Deployment manifest with 3 replicas
