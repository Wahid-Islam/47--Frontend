#!/usr/bin/env bash
# Build Flutter web for Vercel.
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"
export PATH="${FLUTTER_DIR}/bin:${PATH}"

# Production API. Override in Vercel → Settings → Environment Variables.
API_BASE_URL="${API_BASE_URL:-https://47-backend-sandy.vercel.app}"
API_BASE_URL="${API_BASE_URL%/}"

echo "Building Flutter web with API_BASE_URL=${API_BASE_URL}"
flutter --version
flutter build web --release --dart-define="API_BASE_URL=${API_BASE_URL}"
