#!/bin/bash

# Day 42 - Capstone Real-World Project: Microservices Voting App
# This project brings together everything learned in Days 01 to 41:
# Pods, Deployments, ClusterIP, NodePort, CoreDNS Service Discovery, and Self-Healing.

echo "=========================================================="
echo "🚀 Deploying Full Kubernetes Microservices Voting App"
echo "=========================================================="

# Step 1: Deploy In-Memory Queue (Redis) & Internal ClusterIP Service
echo "Step 1: Deploying Redis Queue..."
kubectl apply -f redis.yaml

# Step 2: Deploy Database (PostgreSQL) & Internal ClusterIP Service
echo "Step 2: Deploying PostgreSQL Database..."
kubectl apply -f postgres.yaml

# Step 3: Deploy Background Worker (.NET)
echo "Step 3: Deploying Background Worker..."
kubectl apply -f worker.yaml

# Step 4: Deploy Voting App (Python) & External NodePort Service (Port 30004)
echo "Step 4: Deploying Voting Frontend..."
kubectl apply -f voting-app.yaml

# Step 5: Deploy Result App (Node.js) & External NodePort Service (Port 30005)
echo "Step 5: Deploying Results Analytics Frontend..."
kubectl apply -f result-app.yaml

echo "=========================================================="
echo "⏳ Waiting for all Deployments to be Ready..."
echo "=========================================================="
kubectl rollout status deployment/redis-deploy
kubectl rollout status deployment/postgres-deploy
kubectl rollout status deployment/worker-app-deploy
kubectl rollout status deployment/voting-app-deploy
kubectl rollout status deployment/result-app-deploy

echo "=========================================================="
echo "✅ Verification & Endpoints"
echo "=========================================================="
kubectl get deployments
kubectl get pods -o wide
kubectl get services

echo ""
echo "🎉 Access the Applications:"
echo "👉 Voting App (Cast Votes):   http://<NODE-IP>:30004"
echo "👉 Result App (View Results): http://<NODE-IP>:30005"
echo ""
echo "💡 Tip for Minikube users:"
echo "   minikube service voting-service --url"
echo "   minikube service result-service --url"
