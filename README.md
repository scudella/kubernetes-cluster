# OCI Kubernetes Cluster

This repository documents my self-managed Kubernetes cluster built with **kubeadm**.

The cluster currently consists of four **Oracle Cloud Always Free** ARM (Ampere A1) virtual machines:

| Node  | Role          |
| ----- | ------------- |
| node1 | Control Plane |
| node2 | Worker        |
| node3 | Worker        |
| node4 | Worker        |

The cluster has been running continuously since **2022**.

---

# Repo Architecture

cluster/
├── apps/
│   └──monitoring/
├── networking/
│   └── cilium/
├── docs/
├── backups/
└── README.md

---

# Purpose

This cluster hosts the applications used for my portfolio and several personal projects.

Some applications continue to run on Netlify, while Kubernetes hosts the production containerized workloads.

In addition to Kubernetes, some services currently still run directly on the VMs using **PM2**, including:

* three backend applications
* MariaDB
* PostgreSQL
* one WebRTC application

These services will eventually be migrated away from the Oracle VMs.

---

# Oracle Always Free Changes

In August 2026 Oracle announced a reduction of the Always Free ARM resources from four virtual machines to the equivalent capacity of two virtual machines.

Because of that change, this cluster is being migrated into a **hybrid Kubernetes cluster**, keeping the Oracle control plane while extending the cluster with nodes hosted at home.

As part of this migration, the cluster CNI was migrated from **Weave Net** to **Cilium**.

---

# Networking

## CNI

Current CNI:

* Cilium 1.20
* VXLAN tunneling
* kube-proxy enabled
* Hubble Relay enabled
* WireGuard encryption disabled (planned)
* ClusterMesh not yet enabled

The Kubernetes manifests for the Cilium installation are located under:

```
networking/cilium/
```

---

## Ingress

Ingress is handled by self-managed NGINX reverse proxies running on **node1** and **node2**.

External traffic reaches NGINX, which forwards requests to Kubernetes Services inside the cluster.

The control plane node hosts Kubernetes control components only; application workloads are scheduled on worker nodes.

---

# Monitoring

Monitoring is provided by the kube-prometheus-stack Helm chart.

Currently deployed components include:

* Prometheus
* Grafana
* Alertmanager
* Node Exporter
* kube-state-metrics

These components are managed through Helm.

---

                 Internet
                     |
             +----------------+
             |     NGINX       |
             | node1 / node2   |
             +----------------+
                     |
              Kubernetes Services
                     |
        +------------+------------+
        |            |            |
      node2        node3        node4
       Apps         Apps         Apps

            node1 (Control Plane)
                 kubeadm

         Prometheus / Grafana
          (moving to Home Lab)

                Future

 Oracle Cloud <------ VPN ------> Home Cluster

---

                       Internet
                           │
                     ┌─────┴─────┐
                     │ WireGuard │
                     └─────┬─────┘
                           │
             ┌─────────────┴─────────────┐
             │                           │
        OCI network                  Home network
       10.0.0.0/24                192.168.0.0/24
             │                           │
            node1                     Fedora
      ┌──────┼──────┐──────┐        ┌────┴────┐
      │      │      │      │        │         │
    node4  node2  node3  node1   Fedora    other

---

# Storage

Application manifests are fully version-controlled.

Persistent volumes currently use local host storage located under:

```
/mnt/local-storage/
```

At the moment this includes:

* Grafana
* Prometheus
* Alertmanager

Future work will migrate these volumes to storage hosted on the home infrastructure.

---

# Backup Strategy

Every night a backup job running on **node1** generates:

* etcd snapshot
* Kubernetes manifests
* Kubernetes PKI
* cluster configuration

These backups are copied to the home server.

This repository also serves as infrastructure documentation and disaster recovery documentation.

---

# Virtual Machine Backup

Each Oracle VM currently has a 50 GB boot volume.

Oracle's free block volume backup service protects the boot disks.

Additionally, the home server periodically performs `rsync` backups of all Oracle virtual machines.

---

# OCI Services

The cluster also uses additional Oracle Cloud Always Free services.

## OCI Object Storage

The **store-nextjs** application stores product information in an OCI Object Storage bucket.

## OCI Email Delivery

OCI Email Delivery is used to send application registration and notification emails.

---

# Application Deployment

Application deployments are performed by:

1. Building a Docker image
2. Publishing it to Docker Hub
3. Updating the Kubernetes Deployment with `kubectl set image`

Infrastructure components such as Cilium and the monitoring stack are managed with Helm.

---

# Disaster Recovery

This repository contains the Kubernetes manifests required to recreate the cluster infrastructure, including:

* namespaces
* deployments
* services
* ingress
* monitoring
* Cilium configuration

Persistent volume contents are backed up separately and are not yet recreated automatically.

---

# Current Migration Plan

The immediate objective is to migrate workloads away from Oracle before the Always Free resource reduction.

Planned work includes:

* Add home Kubernetes worker nodes
* Move Prometheus, Grafana and Alertmanager to the home infrastructure
* Migrate the three backend applications currently running under PM2
* Migrate MariaDB and PostgreSQL
* Migrate the email server currently running on node4
* Decommission Oracle nodes 3 and 4

The long-term goal is to operate a stable hybrid Kubernetes cluster spanning Oracle Cloud and the home lab.

