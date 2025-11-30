#!/usr/bin/env bash
set -euo pipefail

# load .env into environment variables
. "$(dirname $0)/load-env.sh"

echo "Node info:"
ssh root@"${KUBE_NODE_IP}"