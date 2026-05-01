#!/bin/bash
# =============================================================================
# cleanup.sh — Remove all Guestbook resources from the cluster
# =============================================================================

set -euo pipefail

MANIFESTS_DIR="$(cd "$(dirname "$0")/../manifests" && pwd)"

echo "========================================"
echo "  Guestbook App — Cleanup"
echo "========================================"

echo ""
echo "Deleting Frontend..."
kubectl delete -f "$MANIFESTS_DIR/frontend-deployment.yaml" --ignore-not-found
kubectl delete -f "$MANIFESTS_DIR/frontend-service-loadbalancer.yaml" --ignore-not-found
kubectl delete -f "$MANIFESTS_DIR/frontend-service-nodeport.yaml" --ignore-not-found

echo ""
echo "Deleting Redis followers..."
kubectl delete -f "$MANIFESTS_DIR/redis-follower-deployment.yaml" --ignore-not-found
kubectl delete -f "$MANIFESTS_DIR/redis-follower-service.yaml" --ignore-not-found

echo ""
echo "Deleting Redis leader..."
kubectl delete -f "$MANIFESTS_DIR/redis-leader-deployment.yaml" --ignore-not-found
kubectl delete -f "$MANIFESTS_DIR/redis-leader-service.yaml" --ignore-not-found

echo ""
echo "All resources removed."
kubectl get pods
