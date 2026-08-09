#!/usr/bin/env bash
# Build Flutter web for Vercel. Requires API_BASE_URL in the project env.
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"
export PATH="${FLUTTER_DIR}/bin:${PATH}"

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "ERROR: Set API_BASE_URL in Vercel Project Settings → Environment Variables"
  echo "Example: https://47-backend.vercel.app  (no trailing slash)"
  exit 1
fi

flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL}"
