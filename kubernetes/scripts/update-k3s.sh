#!/usr/bin/env bash
set -euo pipefail

# load .env into environment variables
. "$(dirname $0)/load-env.sh"

TMP_FILE="/tmp/k3s-config.yaml"

echo "Rendering k3s-config.yaml with environment variables ..."
envsubst < kubernetes/k3s-config.yaml > "$TMP_FILE"

echo "Uploading rendered config to ${KUBE_NODE_IP}:/etc/rancher/k3s/config.yaml ..."
scp "$TMP_FILE" root@"${KUBE_NODE_IP}":/etc/rancher/k3s/config.yaml
rm -f "$TMP_FILE"

echo "Restarting k3s service on ${KUBE_NODE_IP} ..."
ssh root@"${KUBE_NODE_IP}" "systemctl restart k3s && systemctl is-active --quiet k3s && echo 'k3s is active'"

echo "Cluster nodes:"
ssh root@"${KUBE_NODE_IP}" "kubectl get nodes -o wide"

echo "Cluster services (all namespaces):"
ssh root@"${KUBE_NODE_IP}" "kubectl get svc --all-namespaces"

rm -f "$TMP_FILE"