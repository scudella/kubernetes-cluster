#!/bin/bash
set -euo pipefail

helm uninstall cilium -n kube-system
