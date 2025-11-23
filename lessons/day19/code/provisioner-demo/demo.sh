#!/usr/bin/env bash
# Small helper script to run the demo (edit/replace variables before use)
set -euo pipefail

# Usage: ./demo.sh <key_name> <path_to_private_key>
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <key_name> <private_key_path>"
  exit 1
fi

KEY_NAME="$1"
PRIVATE_KEY_PATH="$2"

terraform init
terraform plan -var="key_name=${KEY_NAME}" -var="private_key_path=${PRIVATE_KEY_PATH}"
terraform apply -var="key_name=${KEY_NAME}" -var="private_key_path=${PRIVATE_KEY_PATH}" -auto-approve
