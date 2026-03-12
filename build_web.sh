#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.29.1"
FLUTTER_DIR="$HOME/flutter"

# ── Install Flutter if not already present ─────────────────────────────────
if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C "$HOME"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# ── Precache web artifacts ──────────────────────────────────────────────────
flutter precache --web

# ── Get dependencies ────────────────────────────────────────────────────────
flutter pub get

# ── Build for web ───────────────────────────────────────────────────────────
flutter build web --release
