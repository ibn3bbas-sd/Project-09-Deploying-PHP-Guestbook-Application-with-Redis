#!/bin/bash
# =============================================================================
# deploy-local.sh — Deploy Guestbook App on Minikube or Online Playgrounds
# =============================================================================
# Works with:
#   - Minikube (local)
#   - iximiuz Labs  → https://labs.iximiuz.com/playgrounds?category=kubernetes
#   - Killercoda    → https://killercoda.com/playgrounds/scenario/kubernetes
#   - KodeKloud     → https://kodekloud.com/public-playgrounds
#
# Usage:
#   chmod +x scripts/deploy-local.sh
#   ./scripts/deploy-local.sh
# =============================================================================

set -euo pipefail

MANIFESTS_DIR="$(cd "$(dirname "$0")/../manifests" && pwd)"

echo "========================================"
echo " Guestbook App — Local / Playground"
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
echo "[5/5] Deploying Frontend (NodePort)..."
kubectl apply -f "$MANIFESTS_DIR/frontend-deployment.yaml"
kubectl apply -f "$MANIFESTS_DIR/frontend-service-nodeport.yaml"

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
echo "--------------------------------------"
echo "  Access the Application"
echo "--------------------------------------"

# Detect if running inside minikube
if command -v minikube &>/dev/null; then
  echo ""
  echo "[Minikube] Opening the service in your browser..."
  minikube service frontend
else
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
  echo ""
  echo "[Playground] Open the following URL in your browser or use port-forward:"
  echo ""
  echo "  URL via NodePort : http://${NODE_IP}:30080"
  echo ""
  echo "  Or use port-forward:"
  echo "    kubectl port-forward service/frontend 8080:80"
  echo "  Then open: http://localhost:8080"
fi
