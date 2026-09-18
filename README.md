# OCI Kubernetes Cluster

This repository documents my self-managed Kubernetes cluster built with **kubeadm**.

The cluster used to consist of four **Oracle Cloud Always Free** ARM (Ampere A1) virtual machines:

| Node  | Role          |
| ----- | ------------- |
| node1 | Control Plane |
| node2 | Worker        |
| node3 | Worker        |
| node4 | Worker        |

The cluster has been running continuously since **2022**.

# Oracle Always Free Changes

In August 2026 Oracle announced a reduction of the Always Free ARM resources from four virtual machines to the equivalent capacity of two virtual machines.

Because of that change, this cluster is being migrated into a **hybrid Kubernetes cluster**, keeping the Oracle control plane while extending the cluster with nodes hosted at home.

As part of this migration, the cluster CNI was migrated from **Weave Net** to **Cilium**.

---

Recently, there is an addition of an wireguard vpn connecting OCI and my home. A new fedora machine 
was added to this network as a worker.

---

The current cluster consists of two **Oracle Cloud Always Free** ARM (Ampere A1) virtual machines and 1 fedora machine at home.

There are two additional **Oracle Cloud Always Free** AMD virtual machines that are not part of this cluster as they only have 1GB o RAM.

| Node  | Role          |
| ----- | ------------- |
| node1 | Control Plane |
| node2 | Worker        |
| fedora| Worker        |
| node5 | regular server|
| node6 | regular server|


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

# Networking

## CNI

Current CNI:

* Cilium 1.20
* VXLAN tunneling
* kube-proxy enabled -> disabled after a few days when migrating the pods.
* Hubble Relay enabled
* WireGuard encryption disabled (planned)
* ClusterMesh not yet enabled

The Kubernetes manifests for the Cilium installation are located under:

```
networking/cilium/
```

---

## Ingress

Ingress is handled by self-managed NGINX reverse proxies running on **node1**, **node2**, and **node5**.

External traffic reaches NGINX, which forwards requests to Kubernetes Services inside the cluster, nginx services apps on node6 or AWS lambda api.

The control plane node hosts Kubernetes control components only; application workloads are scheduled on worker nodes. While node2 is off due to out of capacity, control plane is also running apps pods.

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
             | node1 / node2 / |
             |    node5        |
             +----------------+
                     |
              Kubernetes Services
                     |
        +------------+------------+
        |            |            |
      node2        node1        fedora
       Apps         Apps         Apps

            node1 (Control Plane)
                 kubeadm

         Prometheus / Grafana
          (moved to Home Lab)

                Current

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
      ┌──────┼──────┐               ┌────┴────┐
      │      │      │               │         │
    node5  node2  node6           Fedora    other

---

# Storage

Application manifests are fully version-controlled.

Persistent volumes currently use storage hosted on Fedora:

```
/home/local-path-storage
```

At the moment this includes:

* Grafana
* Prometheus
* Alertmanager

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

* Add home Kubernetes worker nodes. Currently added a fedora node.
* Move Prometheus, Grafana and Alertmanager to the home infrastructure. Done
* Migrate the three backend applications currently running under PM2. Currently they were moved from node3 to node2. Still under PM2.
    * jobster/jobify backend has a mongoDB database hosted at Atlas. Moved to node1, as node2 is down.
    * Portfolio backend has a strapi with sqlite3 embedded database.
    * events-backend has a strapi with an external mariaDB database. Both moved to node2. It is down right now.
* Migrate PostgreSQL. Postgres was moved to node2 and is part of kubernetes store-nextjs app. It is down right now.
* Migrate the email server currently running on node4. Done. Moved to node2. It is down right now.
* Decommission Oracle nodes 3 and 4. Done

The long-term goal is to operate a stable hybrid Kubernetes cluster spanning Oracle Cloud and the home lab. Still need to update long running apps and generate amd64 images.

