#!/usr/bin/env bash
# Install Flutter on the Vercel build image (not available by default).
# Cold builders often fail mid-download of the Dart SDK when Flutter's own
# bootstrap curl runs once. We pin a release, shallow-clone it, then download
# the Dart SDK ourselves with retries before first `flutter` use.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.8}"
FLUTTER_DIR="${HOME}/flutter"

download_with_retry() {
  local url="$1"
  local out="$2"
  local attempt=1
  while (( attempt <= 5 )); do
    echo "Download attempt ${attempt}/5: ${url}"
    if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 600 \
      -o "${out}" "${url}"; then
      return 0
    fi
    rm -f "${out}"
    attempt=$((attempt + 1))
    sleep $((attempt * 2))
  done
  return 1
}

if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  echo "Cloning Flutter ${FLUTTER_VERSION}…"
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git \
    -b "${FLUTTER_VERSION}" --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export FLUTTER_SUPPRESS_ANALYTICS=true

ENGINE_VERSION="$(tr -d '[:space:]' < "${FLUTTER_DIR}/bin/internal/engine.version")"
CACHE_DIR="${FLUTTER_DIR}/bin/cache"
DART_ZIP="${CACHE_DIR}/dart-sdk-linux-x64.zip"
DART_URL="https://storage.googleapis.com/flutter_infra_release/flutter/${ENGINE_VERSION}/dart-sdk-linux-x64.zip"

if [[ ! -x "${CACHE_DIR}/dart-sdk/bin/dart" ]]; then
  echo "Prefetching Dart SDK for engine ${ENGINE_VERSION}…"
  mkdir -p "${CACHE_DIR}"
  rm -rf "${CACHE_DIR}/dart-sdk" "${DART_ZIP}"
  download_with_retry "${DART_URL}" "${DART_ZIP}"
  unzip -q "${DART_ZIP}" -d "${CACHE_DIR}"
  rm -f "${DART_ZIP}"
  # Mark stamp so Flutter does not re-download the same SDK.
  echo "${ENGINE_VERSION}" > "${CACHE_DIR}/engine-dart-sdk.stamp"
fi

flutter --version
flutter config --no-analytics --enable-web >/dev/null
flutter precache --web
flutter pub get
