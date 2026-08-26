#!/usr/bin/env bash
# Build an unsigned Release .ipa for sideloading (AltStore resigns on install).
set -euo pipefail

DERIVED="${DERIVED_DATA_PATH:-${RUNNER_TEMP:-/tmp}/DerivedData}"
EXPORT_DIR="${EXPORT_DIR:-${RUNNER_TEMP:-/tmp}/ipa-export}"
IPA_NAME="${IPA_NAME:-Fresco-unsigned.ipa}"

mkdir -p "$DERIVED" "$EXPORT_DIR"

xcodebuild build \
  -project ElementX.xcodeproj \
  -scheme ElementX \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=- \
  DEVELOPMENT_TEAM= \
  PROVISIONING_PROFILE_SPECIFIER= \
  PROVISIONING_PROFILE=

PRODUCTS_DIR="$DERIVED/Build/Products/Release-iphoneos"
# PRODUCT_NAME follows APP_DISPLAY_NAME (Fresco.app), not the Xcode target name (ElementX).
APP_PATH="$(find "$PRODUCTS_DIR" -maxdepth 1 -name '*.app' -type d | head -1)"
if [ ! -d "$APP_PATH" ]; then
  echo "error: no .app bundle found under $PRODUCTS_DIR" >&2
  find "$DERIVED" -name '*.app' >&2 || true
  exit 1
fi

STAGE="$EXPORT_DIR/stage"
rm -rf "$STAGE"
mkdir -p "$STAGE/Payload"
cp -R "$APP_PATH" "$STAGE/Payload/"
(
  cd "$STAGE"
  zip -qr "$EXPORT_DIR/$IPA_NAME" Payload
)
rm -rf "$STAGE"

echo "Built unsigned IPA: $EXPORT_DIR/$IPA_NAME"
