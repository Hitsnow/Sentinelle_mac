#!/bin/bash
# Empaquette build/SentinelMac.app en .dmg via hdiutil (natif macOS, pas de
# dépendance externe type create-dmg).
#
# Usage : VERSION=0.1.0 ./scripts/build_dmg.sh
set -euo pipefail

VERSION="${VERSION:?VERSION requis (ex. 0.1.0)}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/build/SentinelMac.app"
DMG_PATH="$ROOT_DIR/build/SentinelMac-$VERSION.dmg"
STAGING_DIR="$ROOT_DIR/build/dmg-staging"

if [ ! -d "$APP_DIR" ]; then
    echo "$APP_DIR introuvable — lancer scripts/build_app_bundle.sh d'abord" >&2
    exit 1
fi

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"
cp -R "$APP_DIR" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create -volname "Sentinel $VERSION" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"

echo "==> DMG prêt : $DMG_PATH"
