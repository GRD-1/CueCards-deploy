#!/usr/bin/env bash
set -euo pipefail

# load .env into environment variables
. "$(dirname $0)/load-env.sh"

TMP="/tmp/metallb.yaml"

echo "Rendering metallb-addresspool.yaml with environment variables ..."
envsubst < kubernetes/metallb-addresspool.yaml > "$TMP"

echo "Uploading rendered metallb-addresspool.yaml to ${KUBE_NODE_IP}:/root/metallb.yaml ..."
scp "$TMP" root@${KUBE_NODE_IP}:/root/metallb.yaml

echo "Applying rendered metallb-addresspool.yaml to the cluster ..."
ssh root@${KUBE_NODE_IP} "kubectl apply -f /root/metallb.yaml && kubectl -n metallb-system get ipaddresspools,l2advertisements"
rm -f "$TMP"