#!/usr/bin/env bash
set -euo pipefail

# Usage example:
# ./kubernetes/scripts/apply-secrets.sh kubernetes/secrets/cluster-a/ghcr-secrets.yaml cuecards
# This applies the specified YAML file to the 'cuecards' namespace in the cluster.

# load .env into environment variables
. "$(dirname "$0")/load-env.sh"

TMP="$(mktemp)"
REPO_ROOT="$(cd "$(dirname "$0")"/../.. && pwd)"

if [ $# -ne 2 ]; then
  echo "Usage: $0 &lt;file_to_apply&gt; &lt;namespace&gt;"
  exit 1
fi
FILE_PATH="$1"
NAMESPACE="$2"
BASENAME=$(basename "$FILE_PATH")

if [[ $FILE_PATH = /* ]]; then
  FULL_PATH="$FILE_PATH"
else
  FULL_PATH="$REPO_ROOT/$FILE_PATH"
fi

if [ ! -f "$FULL_PATH" ]; then
  echo "Error: File $FULL_PATH does not exist."
  exit 1
fi

if [ -z "$NAMESPACE" ]; then
  echo "Error: Namespace cannot be empty."
  exit 1
fi

echo "Applying $BASENAME to namespace $NAMESPACE in the cluster ..."

envsubst < "$FULL_PATH" > "$TMP"
scp "$TMP" "root@${KUBE_NODE_IP}:/root/$BASENAME"
ssh "root@${KUBE_NODE_IP}" "kubectl apply -n $NAMESPACE -f /root/$BASENAME"

rm -f "$TMP"

echo "Done. The file $BASENAME should now be applied in namespace $NAMESPACE."