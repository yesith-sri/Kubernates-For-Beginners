#!/bin/bash

# Day 42 - Capstone Real-World Project: Microservices Voting App
# Official KodeKloud Specification: https://github.com/kodekloudhub/example-voting-app
# This script deploys all 5 microservices in logical order (Step 1 to Step 5)

echo "=========================================================="
echo "🚀 Deploying KodeKloud Microservices Voting App"
echo "=========================================================="

# Step 1: Deploy In-Memory Queue (Redis) + ClusterIP Service (Port 6379)
echo "Step 1: Deploying Redis Queue..."
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml

# Step 2: Deploy PostgreSQL Database (db) + ClusterIP Service (Port 5432)
echo "Step 2: Deploying PostgreSQL Database..."
kubectl apply -f db-deployment.yaml
kubectl apply -f db-service.yaml

# Step 3: Deploy Background Worker (.NET)
echo "Step 3: Deploying Background Worker..."
kubectl apply -f worker-deployment.yaml

# Step 4: Deploy Voting App (Python) + NodePort Service (Port 31000)
echo "Step 4: Deploying Voting Frontend..."
kubectl apply -f vote-deployment.yaml
kubectl apply -f vote-service.yaml

# Step 5: Deploy Result App (Node.js) + NodePort Service (Port 31001)
echo "Step 5: Deploying Results Analytics Frontend..."
kubectl apply -f result-deployment.yaml
kubectl apply -f result-service.yaml

echo "=========================================================="
echo "⏳ Waiting for all Deployments to be Ready..."
echo "=========================================================="
kubectl rollout status deployment/redis
kubectl rollout status deployment/db
kubectl rollout status deployment/worker
kubectl rollout status deployment/vote
kubectl rollout status deployment/result

echo "=========================================================="
echo "✅ Verification & Endpoints"
echo "=========================================================="
kubectl get deployments
kubectl get pods -o wide
kubectl get services

echo ""
echo "🎉 Access the Applications:"
echo "👉 Voting App (Cast Votes):   http://<NODE-IP>:31000"
echo "👉 Result App (View Results): http://<NODE-IP>:31001"
echo ""
echo "💡 Tip for Minikube users:"
echo "   minikube service vote-service --url"
echo "   minikube service result-service --url"
