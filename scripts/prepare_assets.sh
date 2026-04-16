#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="$ROOT_DIR/assets/public"
PRIVATE_DIR="$ROOT_DIR/assets/local_private"
GENERATED_DIR="$ROOT_DIR/assets/generated"

if [[ ! -d "$PUBLIC_DIR" ]]; then
  echo "Missing public assets directory: $PUBLIC_DIR" >&2
  exit 1
fi

rm -rf "$GENERATED_DIR"
mkdir -p "$GENERATED_DIR"

rsync -a --delete "$PUBLIC_DIR/" "$GENERATED_DIR/"

if [[ -d "$PRIVATE_DIR" ]]; then
  rsync -a "$PRIVATE_DIR/" "$GENERATED_DIR/"
fi

echo "Prepared generated assets at: $GENERATED_DIR"
