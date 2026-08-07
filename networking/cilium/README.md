# Cilium Networking

This directory contains the configuration used to deploy Cilium as the Kubernetes
Container Network Interface (CNI) for the cluster.

## Overview

The cluster uses:

- Kubernetes: kubeadm
- Kubernetes version: 1.33.x
- Cilium: 1.20.x
- Oracle Cloud Always Free (Ampere ARM)
- 4-node cluster

## Current Configuration

- Routing Mode: VXLAN Tunnel
- kube-proxy: Enabled
- IPAM: Cluster Pool
- Pod CIDR: 10.32.0.0/12
- Encryption: Disabled
- Hubble Relay: Enabled
- Hubble UI: Disabled
- Prometheus Metrics: Enabled

## Why these settings?

### VXLAN

VXLAN provides the simplest deployment across Oracle Cloud without requiring
native routing or cloud-specific integration.

### kube-proxy

The cluster currently keeps kube-proxy enabled to minimize migration risk.

Future evaluation may enable Cilium's kube-proxy replacement.

### Encryption

Encryption is intentionally disabled.

The cluster was first migrated with encryption disabled to simplify debugging.
WireGuard encryption may be enabled after the infrastructure expansion.

### Hubble

Hubble Relay is enabled for network observability.

The Hubble UI is currently disabled because Relay provides sufficient
functionality while consuming fewer resources.

## Migration History

Original CNI:

- Weave Net 2.9

Migration completed:

- August 2026

Migration validation included:

- Pod-to-pod connectivity
- Service connectivity
- DNS resolution
- Ingress validation
- Rolling reboot of every node
- Removal of remaining Weave interfaces

## Future Improvements

Planned work includes:

- Add home-based Kubernetes nodes
- Evaluate Cilium ClusterMesh
- Enable WireGuard encryption
- Evaluate kube-proxy replacement
- Improve observability with Hubble metrics
