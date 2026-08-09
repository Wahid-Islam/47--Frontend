#!/usr/bin/env bash
# Install Flutter on the Vercel build image (not available by default).
set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  echo "Cloning Flutter stable SDK…"
  rm -rf "${FLUTTER_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter config --no-analytics --enable-web
flutter precache --web
flutter pub get
