#! /bin/bash

set -e

# Base secrets file path
SECRETS_DIR="/run/secrets"
SECRETS_FILE="$SECRETS_DIR/env"

# Load the primary secrets file if it exists
if [[ -f "$SECRETS_FILE" ]]; then
  set -o allexport
  source "$SECRETS_FILE"
  set +o allexport
  echo "Environment variables from $SECRETS_FILE have been loaded."
else
  echo "Secrets file $SECRETS_FILE does not exist."
fi

# Load additional env files following the env_\d+ pattern
for file in "$SECRETS_DIR"/env_*; do
  if [[ -f "$file" && "$file" =~ env_[0-9]+ ]]; then
    set -o allexport
    source "$file"
    set +o allexport
    echo "Environment variables from $file have been loaded."
  fi
done

set +e
envsubst_output=$(envsubst -no-unset -no-empty -i /caddy.config.template.json -o /caddy.config.json 2>&1)
envsubst_exit_code=$?
set -e

if [[ $envsubst_exit_code -ne 0 ]]; then
  echo "$envsubst_output" | sort | uniq
  exit $envsubst_exit_code
fi

cat /caddy.config.json | jq . && caddy run --config /caddy.config.json