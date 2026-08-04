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

echo "Helm values validated."

echo "Installing Cilium chart ${CHART_VERSION}"

helm upgrade \
    --install \
    cilium \
    cilium/cilium \
    --version "${CHART_VERSION}" \
    --namespace kube-system \
    --create-namespace \
    --wait \
    --timeout 15m \
    -f "${SCRIPT_DIR}/values.yaml"

echo
echo "Checking Cilium status..."
kubectl -n kube-system rollout status ds/cilium --timeout=10m
kubectl -n kube-system rollout status deployment/cilium-operator --timeout=10m

echo
echo "Installed successfully."
