#!/bin/bash
# Signe le .dmg (clé privée Sparkle EdDSA) et régénère appcast.xml.
#
# Suit le flux documenté par Sparkle 2.x : `generate_appcast` scanne un
# dossier contenant TOUTES les versions déjà publiées (releases/*.dmg) et
# reconstruit l'appcast complet à partir de leurs Info.plist embarqués — on
# ne signe/génère donc jamais un item isolé à la main.
#
# Usage : VERSION=0.1.0 SPARKLE_PRIVATE_KEY="..." ./scripts/sign_and_update_appcast.sh
#
# NOTE : les noms d'options exacts de `generate_appcast`/`sign_update`
# peuvent varier légèrement selon la version de Sparkle résolue par SPM —
# à vérifier/ajuster au premier run CI (cf. `sparkle-project/Sparkle` docs,
# section "Publishing an Update").
set -euo pipefail

VERSION="${VERSION:?VERSION requis}"
SPARKLE_PRIVATE_KEY="${SPARKLE_PRIVATE_KEY:?SPARKLE_PRIVATE_KEY requis (secret GitHub Actions)}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASES_DIR="$ROOT_DIR/releases"
DMG_SRC="$ROOT_DIR/build/SentinelMac-$VERSION.dmg"

mkdir -p "$RELEASES_DIR"
cp "$DMG_SRC" "$RELEASES_DIR/"

echo "==> Récupération des outils Sparkle (generate_appcast, sign_update)"
SPARKLE_TOOLS_DIR="$ROOT_DIR/.sparkle-tools"
if [ ! -x "$SPARKLE_TOOLS_DIR/bin/generate_appcast" ]; then
    SPARKLE_VERSION="2.6.4"
    curl -L -o /tmp/sparkle.tar.xz \
        "https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/Sparkle-${SPARKLE_VERSION}.tar.xz"
    mkdir -p "$SPARKLE_TOOLS_DIR"
    tar -xf /tmp/sparkle.tar.xz -C "$SPARKLE_TOOLS_DIR"
fi

echo "==> Écriture temporaire de la clé privée (fichier éphémère, runner CI jetable)"
KEY_FILE=$(mktemp)
trap 'rm -f "$KEY_FILE"' EXIT
printf '%s' "$SPARKLE_PRIVATE_KEY" > "$KEY_FILE"

echo "==> Régénération de l'appcast à partir de tout releases/"
"$SPARKLE_TOOLS_DIR/bin/generate_appcast" --ed-key-file "$KEY_FILE" "$RELEASES_DIR"

cp "$RELEASES_DIR/appcast.xml" "$ROOT_DIR/appcast.xml"
echo "==> appcast.xml mis à jour"
