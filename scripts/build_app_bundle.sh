#!/bin/bash
# Assemble SentinelMac.app à partir du binaire compilé par `swift build`.
# Pas de projet Xcode (.xcodeproj) : on construit le bundle .app à la main,
# d'où ce script plutôt qu'une phase "Embed Frameworks" native.
#
# Usage : VERSION=0.1.0 SPARKLE_PUBLIC_KEY=... ./scripts/build_app_bundle.sh
set -euo pipefail

VERSION="${VERSION:?VERSION requis (ex. 0.1.0, sans le v du tag git)}"
SPARKLE_PUBLIC_KEY="${SPARKLE_PUBLIC_KEY:?SPARKLE_PUBLIC_KEY requis}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
APP_NAME="SentinelMac"
APP_DIR="$ROOT_DIR/build/$APP_NAME.app"

echo "==> swift build (release, universel arm64+x86_64)"
cd "$ROOT_DIR"
swift build -c release --arch arm64 --arch x86_64

BIN_PATH=$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/$APP_NAME
if [ ! -f "$BIN_PATH" ]; then
    echo "Binaire introuvable à $BIN_PATH" >&2
    exit 1
fi

echo "==> Assemblage du bundle .app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Frameworks"

cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"

sed -e "s/0\\.0\\.0/$VERSION/" \
    -e "s/__SPARKLE_PUBLIC_KEY__/$SPARKLE_PUBLIC_KEY/" \
    "$ROOT_DIR/Resources/Info.plist" > "$APP_DIR/Contents/Info.plist"
# CFBundleVersion (build number) : on réutilise VERSION sans les points pour
# rester monotone (ex. 0.1.0 -> 010) — Sparkle compare CFBundleVersion.
BUILD_NUMBER=$(echo "$VERSION" | tr -d '.')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP_DIR/Contents/Info.plist"

echo "==> Recherche de Sparkle.framework dans les artefacts SPM"
SPARKLE_FRAMEWORK=$(find "$BUILD_DIR" -type d -name "Sparkle.framework" | head -1)
if [ -z "$SPARKLE_FRAMEWORK" ]; then
    echo "Sparkle.framework introuvable sous $BUILD_DIR — la structure des" >&2
    echo "artefacts SPM de Sparkle a peut-être changé, à ajuster ici." >&2
    exit 1
fi
cp -R "$SPARKLE_FRAMEWORK" "$APP_DIR/Contents/Frameworks/"

echo "==> Signature ad-hoc (pas de compte Apple Developer)"
codesign --force --deep --sign - "$APP_DIR/Contents/Frameworks/Sparkle.framework"
codesign --force --deep --sign - "$APP_DIR"

echo "==> Bundle prêt : $APP_DIR (version $VERSION, build $BUILD_NUMBER)"
