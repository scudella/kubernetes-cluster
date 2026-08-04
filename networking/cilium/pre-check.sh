#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


CHART_VERSION="1.20.0"

echo "Current nodes:"
kubectl get nodes

echo
echo "Current CNI:"
kubectl -n kube-system get ds weave-net

echo
echo "Existing Cilium:"
kubectl -n kube-system get ds cilium || true

helm repo add cilium https://helm.cilium.io >/dev/null 2>&1 || true
helm repo update

echo
echo "Validating Helm values..."
helm template \
    cilium \
    cilium/cilium \
    --version "${CHART_VERSION}" \
    -f "${SCRIPT_DIR}/values.yaml" \
    >/dev/null

