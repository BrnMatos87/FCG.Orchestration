#!/bin/sh
set -eu

: "${FCG_JWT_SECRET:?FCG_JWT_SECRET is required}"

template_path="${KONG_TEMPLATE_PATH:-/kong/template/kong.yml}"
output_path="${KONG_RENDERED_PATH:-/kong/declarative/kong.yml}"
encoded_secret="$(printf '%s' "$FCG_JWT_SECRET" | base64 | tr -d '\n')"

sed "s|__FCG_JWT_SECRET_BASE64__|${encoded_secret}|g" \
  "$template_path" > "$output_path"
