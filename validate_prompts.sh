#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
SCHEMA="$ROOT/schema/prompt-schema.json"
FAILED=0
for f in $(find "$ROOT/prompts" -name '*.md');
do
  JSON=$(sed -n '/^{/,/^}/p' "$f" | sed -n '1,$p')
  if [ -z "$JSON" ];
  then
    echo "WARN: No JSON metadata in $f"
    continue
  fi
  echo "$JSON" > /tmp/_prompt_meta.json
  if !
  jq -e . /tmp/_prompt_meta.json >/dev/null 2>&1; then
    echo "ERROR: Invalid JSON in $f"
    FAILED=1
    continue
  fi
  if !
  ajv validate -s "$SCHEMA" -d /tmp/_prompt_meta.json >/dev/null 2>&1; then
    echo "ERROR: Schema validation failed for $f"
    FAILED=1
  else
    echo "OK: $f"
  fi
done
exit $FAILED
