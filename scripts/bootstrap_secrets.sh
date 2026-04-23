#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ANDROID_SECRETS_FILE="$ROOT_DIR/android/secrets.properties"
IOS_SECRETS_FILE="$ROOT_DIR/ios/Flutter/Secrets.xcconfig"
ANDROID_FIREBASE_FILE="$ROOT_DIR/android/app/google-services.json"
IOS_FIREBASE_FILE="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"

mkdir -p "$ROOT_DIR/android" "$ROOT_DIR/ios/Flutter" "$ROOT_DIR/android/app" "$ROOT_DIR/ios/Runner"

if [[ -n "${GOOGLE_MAPS_API_KEY:-}" ]]; then
  cat > "$ANDROID_SECRETS_FILE" <<EOF
GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
EOF

  cat > "$IOS_SECRETS_FILE" <<EOF
GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
EOF
fi

if [[ -n "${FIREBASE_ANDROID_JSON_B64:-}" ]]; then
  echo "$FIREBASE_ANDROID_JSON_B64" | base64 --decode > "$ANDROID_FIREBASE_FILE"
fi

if [[ -n "${FIREBASE_IOS_PLIST_B64:-}" ]]; then
  echo "$FIREBASE_IOS_PLIST_B64" | base64 --decode > "$IOS_FIREBASE_FILE"
fi

echo "Secret bootstrap completed."
