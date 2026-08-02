# Monitoring Stack

This directory contains the configuration for the monitoring stack deployed with Helm.

## Components

- Prometheus
- Grafana
- Alertmanager
- Prometheus Operator
- kube-state-metrics
- node-exporter

## To recover helm applications

This gives you everything needed to rebuild the monitoring stack:

Create the directories on the node(s). See persistence storage below.

Set the documented ownership and permissions. See persistence storage below.
Apply the PersistentVolume manifests. See persistence storage below.

Install kube-prometheus-stack with values.yaml.
Assuming you already have:

the prometheus-community Helm repository added,

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Use the installation command under Install below.

For an upgrade after changing values.yaml, see Upgrade below.

## Install

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --version 79.0.0 \
  -f values.yaml

One recommendation: pinning the chart version (79.0.0) is exactly the right approach. If you omit --version, Helm will install the latest available chart, which may have different defaults or even breaking changes. Keeping the version fixed makes your cluster reproducible months or years later.

## Upgrade

helm upgrade prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 79.0.0 \
  -f values.yaml

## Persistence storage

Create the directories on the node that will host the monitoring stack:

currently node3:

node3 and node4
/mnt/local-storage
owner: root
group: root
permissions: 755

node3
/mnt/local-storage/prometheus
owner: prometheus
group: prometheus
permissions: 755

node4
/mnt/local-storage/prometheus
owner: prometheus
group: prometheus
permissions: 770

node3
/mnt/local-storage/prometheus/grafana
owner: 472
group: 472
permissions: 755

ls -l /mnt/local-storage/prometheus/grafana/
total 2716
drwxr-xr-x 2 472 472    4096 Oct 30  2025 csv
-rwxr-xr-x 1 472 472 2760704 Aug  2 18:06 grafana.db
drwxr-xr-x 2 472 472    4096 Oct 30  2025 pdf
drwxr-xr-x 6 472 472    4096 Mar 19 20:32 plugins
drwxr-xr-x 2 472 472    4096 Oct 30  2025 png

node4
/mnt/local-storeage/prometheus/alertmanager
owner: prometheus
group: 2000
permission: 770

/mnt/local-storage/prometheus/prometheus/
owner: prometheus
group: prometheus
permission: 770

/mnt/local-storage/prometheus/grafana
owner: 472
group: 472
permission: 755

other directories in node4
k8s@node4:~$ sudo ls -l /mnt/local-storage/prometheus/alertmanager
total 4
drwxrwx--- 2 prometheus 2000 4096 Aug  2 18:41 alertmanager-db
k8s@node4:~$ sudo ls -l /mnt/local-storage/prometheus/grafana
total 2144
drwx------ 2 472 472    4096 Oct 30  2025 csv
-rw-r----- 1 472 472 2174976 Oct 30  2025 grafana.db
drwx------ 2 472 472    4096 Oct 30  2025 pdf
drwxr-xr-x 6 472 472    4096 Oct 30  2025 plugins
drwx------ 2 472 472    4096 Oct 30  2025 png
k8s@node4:~$ sudo ls -l /mnt/local-storage/prometheus/prometheus
total 4
drwxrwx--- 21 prometheus prometheus 4096 Aug  2 17:00 prometheus-db
k8s@node4:~$ sudo ls -l /mnt/local-storage/prometheus/alertmanager/alertmanager-db
total 0
-rw-r--r-- 1 prometheus 2000 0 Aug  2 18:56 nflog
-rw-r--r-- 1 prometheus 2000 0 Aug  2 18:56 silences
k8s@node4:~$ sudo ls -l /mnt/local-storage/prometheus/prometheus/prometheus-db
total 100
drwxr-xr-x 3 prometheus prometheus  4096 Jul 24 05:00 01KY97XMBH048MKZJBJXVARDEF
drwxr-xr-x 3 prometheus prometheus  4096 Jul 24 23:00 01KYB5Q47DCPP4RBT6RAXQG5JA
drwxr-xr-x 3 prometheus prometheus  4096 Jul 25 17:00 01KYD3GNE2KJCSA0YP47SNG24F
drwxr-xr-x 3 prometheus prometheus  4096 Jul 26 11:00 01KYF1A70MVCDSFVF5KTSBXDHV
drwxr-xr-x 3 prometheus prometheus  4096 Jul 27 05:00 01KYGZ3RHFH3F4E08BYNP5PQ1B
drwxr-xr-x 3 prometheus prometheus  4096 Jul 27 23:00 01KYJWX9JPF8HZMNCVZX6ZW34B
drwxr-xr-x 3 prometheus prometheus  4096 Jul 28 17:00 01KYMTPRQH5NYT4RMJZENX70RP
drwxr-xr-x 3 prometheus prometheus  4096 Jul 29 09:00 01KYPHMCH7QHZYE0SC2F90E7T2
drwxr-xr-x 3 prometheus prometheus  4096 Jul 30 05:00 01KYRP9R5WMDTY5BP7C2DRT7P8
drwxr-xr-x 3 prometheus prometheus  4096 Jul 30 23:00 01KYTM39DRXXGTF7B21518W7SG
drwxr-xr-x 3 prometheus prometheus  4096 Jul 31 17:00 01KYWHWTT90B24KSBG0N4C3HVT
drwxr-xr-x 3 prometheus prometheus  4096 Aug  1 11:00 01KYYFPBRTECGXM6FQ5VCAJ5VA
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 05:00 01KZ0DFX1J0Q63VVP2Q54SW7HY
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 11:00 01KZ122ZVXC8FF0S27FKTQA6EY
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 15:00 01KZ1FTC2ZVDW4A7EBJ4P46GWN
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 17:00 01KZ1PP3AXGX015SNNYYVSYGR2
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 17:00 01KZ1PP5R9Y0C4WP3X942NZ14X
drwxr-xr-x 3 prometheus prometheus  4096 Aug  2 19:00 01KZ1XHTJCZRRM1051RMRGFYD8
drwxrwx--- 2 prometheus prometheus  4096 Aug  2 19:00 chunks_head
-rw-r--r-- 1 prometheus prometheus     0 Jul 24 06:38 lock
-rwxrwx--- 1 prometheus prometheus 20001 Aug  2 18:59 queries.active
drwxr-xr-x 4 prometheus prometheus  4096 Aug  2 19:00 wal


Apply the PersistentVolumes:

```bash
kubectl apply -f persistent-volumes.yaml
```

