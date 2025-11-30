#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
ENV_FILE="${SCRIPT_DIR}/../.env"

if [ ! -f "$ENV_FILE" ]; then
  echo ".env file not found at ${ENV_FILE}" >&2
  exit 1
fi

# Load variables into environment
set -a
. "$ENV_FILE"
set +a

# Print variables loaded from .env
echo "Loaded environment variables:"
grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE" | sed 's/=.*//' | while read -r var; do
  printf "%s=%s\n" "$var" "${!var-}"
done
echo