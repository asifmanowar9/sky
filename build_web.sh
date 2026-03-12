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

# ── Silence the "running as root" warning ───────────────────────────────────
export FLUTTER_SUPPRESS_ANALYTICS=1
export PUB_ENVIRONMENT=vercel

# ── Precache web artifacts ──────────────────────────────────────────────────
flutter precache --web --no-version-check

# ── Get dependencies ────────────────────────────────────────────────────────
flutter pub get --no-version-check

# ── Build for web ───────────────────────────────────────────────────────────
flutter build web --release --no-version-check
