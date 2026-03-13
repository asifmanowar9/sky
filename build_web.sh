#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.29.1"
FLUTTER_DIR="/vercel/flutter"

# ── Fix git "dubious ownership" error when running as root on Vercel ────────
git config --global --add safe.directory "$FLUTTER_DIR" || true

# ── Install Flutter if not already present ─────────────────────────────────
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  mkdir -p "$FLUTTER_DIR"
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ --strip-components=1 -C "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
export PUB_ENVIRONMENT=vercel_ci

# ── Build for web (runs pub get automatically if needed) ────────────────────
flutter build web --release
