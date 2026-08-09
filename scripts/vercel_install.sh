#!/usr/bin/env bash
# Install Flutter on the Vercel build image (not available by default).
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter config --no-analytics
flutter precache --web
flutter pub get
