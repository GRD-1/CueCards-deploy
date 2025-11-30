#!/usr/bin/env bash
set -euo pipefail

# load .env into environment variables
. "$(dirname "$0")/load-env.sh"

TMP="$(mktemp)"
REPO_ROOT="$(cd "$(dirname "$0")"/../.. && pwd)"
APP_TMP="$(mktemp)"

# echo "Rendering values with environment variables ..."
# envsubst < "$REPO_ROOT/kubernetes/infra/argocd/values.yaml" > "$TMP"

# echo "Uploading rendered values to ${KUBE_NODE_IP}:/root/argocd-values.yaml ..."
# scp "$TMP" "root@${KUBE_NODE_IP}:/root/argocd-values.yaml"

# echo "Upgrading/Installing Argo CD on remote cluster ..."
# ssh "root@${KUBE_NODE_IP}" "helm upgrade --install argocd argo/argo-cd \
#   --namespace argocd --create-namespace \
#   -f /root/argocd-values.yaml && kubectl -n argocd get pods"

echo "Applying argocd-cluster-bootstrap manifest to the cluster ..."
envsubst < "$REPO_ROOT/kubernetes/infra/argocd/argocd-cluster-bootstrap.yaml" > "$APP_TMP"
scp "$APP_TMP" "root@${KUBE_NODE_IP}:/root/argocd-cluster-bootstrap.yaml"
ssh "root@${KUBE_NODE_IP}" "kubectl apply -n argocd -f /root/argocd-cluster-bootstrap.yaml && kubectl -n argocd get applications.argoproj.io"

rm -f "$TMP" "$APP_TMP"