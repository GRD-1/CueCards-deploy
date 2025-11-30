#!/usr/bin/env bash
set -euo pipefail
. "$(dirname $0)/load-env.sh"

SRC="kubernetes/infra/network/ingress-controller.yaml"
TMP="/tmp/ingress-controller.yaml"

echo "Rendering $SRC with environment variables ..."
envsubst < "$SRC" > "$TMP"

echo "Uploading rendered $SRC to ${KUBE_NODE_IP}:/root/ingress-controller.yaml ..."
scp "$TMP" root@${KUBE_NODE_IP}:/root/ingress-controller.yaml
rm -f "$TMP"

echo "Applying rendered ingress-controller.yaml to the cluster ..."
ssh root@${KUBE_NODE_IP} "kubectl apply -f /root/ingress-controller.yaml && kubectl -n ingress-nginx get svc ingress-nginx-controller -o wide"