#!/bin/bash
# =============================================================================
# deploy-oke.sh — Deploy Guestbook App on Oracle Kubernetes Engine (OKE)
# =============================================================================
# Prerequisites:
#   - OCI CLI configured (oci setup config)
#   - OKE cluster created and kubeconfig set up
#   - kubectl installed
#
# Usage:
#   chmod +x scripts/deploy-oke.sh
#   ./scripts/deploy-oke.sh
# =============================================================================

set -euo pipefail

MANIFESTS_DIR="$(cd "$(dirname "$0")/../manifests" && pwd)"

echo "========================================"
echo "  Guestbook App — OKE Deployment"
echo "========================================"

echo ""
echo "[1/5] Deploying Redis leader..."
kubectl apply -f "$MANIFESTS_DIR/redis-leader-deployment.yaml"
kubectl apply -f "$MANIFESTS_DIR/redis-leader-service.yaml"

echo ""
echo "[2/5] Waiting for Redis leader to be ready..."
kubectl rollout status deployment/redis-leader --timeout=120s

echo ""
echo "[3/5] Deploying Redis followers..."
kubectl apply -f "$MANIFESTS_DIR/redis-follower-deployment.yaml"
kubectl apply -f "$MANIFESTS_DIR/redis-follower-service.yaml"

echo ""
echo "[4/5] Waiting for Redis followers to be ready..."
kubectl rollout status deployment/redis-follower --timeout=120s

echo ""
echo "[5/5] Deploying Frontend (LoadBalancer)..."
kubectl apply -f "$MANIFESTS_DIR/frontend-deployment.yaml"
kubectl apply -f "$MANIFESTS_DIR/frontend-service-loadbalancer.yaml"

echo ""
echo "[INFO] Waiting for Frontend to be ready..."
kubectl rollout status deployment/frontend --timeout=120s

echo ""
echo "========================================"
echo "  Deployment Complete!"
echo "========================================"
echo ""
echo "Pods:"
kubectl get pods -o wide

echo ""
echo "Services:"
kubectl get services

echo ""
echo "[INFO] Waiting for external IP from OCI Load Balancer..."
echo "[INFO] Run the following command to watch for the EXTERNAL-IP:"
echo ""
echo "  kubectl get service frontend --watch"
echo ""
echo "Once the EXTERNAL-IP is assigned, open http://<EXTERNAL-IP> in your browser."
