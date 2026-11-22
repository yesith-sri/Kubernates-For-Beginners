#!/bin/bash

# Day 11 - Deployments vs ReplicaSets

# Step 1: View the Deployment YAML
cat deployment.yaml

# Step 2: Create the Deployment
kubectl apply -f deployment.yaml

# Step 3: Check the Deployment
# READY 3/3 means all 3 replicas are running
kubectl get deployments

# Step 4: Check the ReplicaSet
# Automatically created by the Deployment — you never created this
kubectl get replicasets

# Step 5: Check the Pods
# 3 Pods created by the ReplicaSet
# One Deployment -> One ReplicaSet -> Three Pods
kubectl get pods

# Step 6: Test Self-Healing — Delete one Pod and watch it recover instantly
# We intentionally delete one Pod to simulate a crash or accidental deletion:
echo "Deleting one Pod to test self-healing..."
POD_NAME=$(kubectl get pods -l app=my-app -o jsonpath="{.items[0].metadata.name}")
kubectl delete pod $POD_NAME

# The ReplicaSet immediately detects that 2 < 3 and creates a new Pod:
echo "Checking Pods immediately after deletion — notice the new Pod with low age:"
kubectl get pods
