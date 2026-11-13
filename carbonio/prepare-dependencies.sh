#!/usr/bin/env bash
set -Eeuo pipefail

HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_DIR="$HERE/.upstream/carbonio-dockerization-tools"
SOURCE_DIR="$UPSTREAM_DIR/internal/embedded/carbonio-dockerization"

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is required." >&2
  exit 1
fi

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
  mkdir -p "$HERE/.upstream"
  git clone --depth 1 https://github.com/zextras/carbonio-dockerization-tools.git "$UPSTREAM_DIR"
else
  git -C "$UPSTREAM_DIR" pull --ff-only
fi

if [[ ! -f "$SOURCE_DIR/docker-compose.yaml" ]]; then
  echo "ERROR: upstream Carbonio Compose assets were not found at: $SOURCE_DIR" >&2
  exit 1
fi

for directory in consul-service-registrator provisioning consul postgres carbonio-docs-editor composed-ui ssl; do
  if [[ ! -d "$SOURCE_DIR/$directory" ]]; then
    echo "ERROR: required upstream directory is missing: $directory" >&2
    exit 1
  fi
  rm -rf -- "$HERE/$directory"
  cp -a -- "$SOURCE_DIR/$directory" "$HERE/$directory"
done

echo "Carbonio helper files are ready."
echo "Next: cp .env.example .env, set strong secrets, then review README.md."
