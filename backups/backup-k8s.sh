#!/bin/bash
umask 027
set -euo pipefail

trap 'rm -f "$BACKUP_DIR"/k8s-manifests-"$DATE".yaml.part' ERR

export KUBECONFIG=/etc/kubernetes/admin.conf

log() {
    echo "[$(date '+%F %T')] $*"
}

BACKUP_DIR="/var/backups/etcd"
DATE=$(date +%F-%H%M)

mkdir -p "$BACKUP_DIR"

log "Creating etcd snapshot..."

ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save "$BACKUP_DIR/etcd-$DATE.db"

ETCDCTL_API=3 etcdctl snapshot status \
    "$BACKUP_DIR/etcd-$DATE.db" \
    >/dev/null

gzip -f "$BACKUP_DIR/etcd-$DATE.db"

log "Backing up Kubernetes Config & PKI (including encryption keys if present)..."
# Backs up PKI + API server configs/manifests
tar czf "$BACKUP_DIR/k8s-config-$DATE.tar.gz" \
    /etc/kubernetes/pki \
    /etc/kubernetes/manifests \
    /etc/kubernetes/*.conf

log "Exporting Kubernetes manifests..."
# Explicitly lists secrets, RBAC, and storage manifests
kubectl get \
    all,cm,ingress,pvc,pv,networkpolicy,serviceaccount,role,rolebinding,clusterrole,clusterrolebinding,crd \
    -A -o yaml > "$BACKUP_DIR/k8s-manifests-$DATE.yaml.part"

mv "$BACKUP_DIR/k8s-manifests-$DATE.yaml.part" "$BACKUP_DIR/k8s-manifests-$DATE.yaml"

log "Saving kubernetes version and other info"
{
    echo "===== Kubernetes Version ====="
    kubectl version

    echo
    echo "===== Nodes ====="
    kubectl get nodes -o wide

    echo
    echo "===== StorageClasses ====="
    kubectl get storageclass

    echo
    echo "===== Namespaces ====="
    kubectl get ns
} > "$BACKUP_DIR/cluster-info-$DATE.txt"

# Make backups readable by the backups group
# Set permissions
chgrp -R backups "$BACKUP_DIR"

chmod 640 \
    "$BACKUP_DIR"/etcd-"$DATE".db.gz \
    "$BACKUP_DIR"/k8s-config-"$DATE".tar.gz \
    "$BACKUP_DIR"/k8s-manifests-"$DATE".yaml

log "Removing backups older than 30 days..."

cd "$BACKUP_DIR"
ls -1t etcd-*.db.gz | tail -n +31 | xargs -r rm
ls -1t k8s-config*.tar.gz | tail -n +31 | xargs -r rm
ls -1t k8s-manifests*.yaml | tail -n +31 | xargs -r rm

log "Calculating checksums..."
rm -f SHA256SUMS
find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 \
    | sort -z \
    | xargs -0 sha256sum > SHA256SUMS

log "Backup completed successfully"

log "Generated:"
ls -lh "$BACKUP_DIR"/etcd-"$DATE".db.gz
ls -lh "$BACKUP_DIR"/k8s-config-"$DATE".tar.gz
ls -lh "$BACKUP_DIR"/k8s-manifests-"$DATE".yaml

log "Done."

