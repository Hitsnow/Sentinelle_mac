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
# SPARKLE_PRIVATE_KEY doit être la valeur EXPORTÉE via `generate_keys -x` sur
# le Mac de Pierre (blob combiné privé+public, 128 caractères base64) — PAS
# la valeur retournée par `security find-generic-password` seule, qui est
# incomplète (confirmé en lisant generate_appcast/main.swift : la vraie
# valeur stockée en Keychain fait 128 caractères, pas 44).
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

echo "==> Régénération de l'appcast à partir de tout releases/"
# -s : seul flag réel de generate_appcast pour une clé EdDSA fournie en
# argument (confirmé dans generate_appcast/main.swift) — pas de fichier,
# valeur directe. Le contenu du secret ne doit jamais apparaître dans les
# logs : la commande elle-même n'est pas affichée (set -x n'est pas activé).
"$SPARKLE_TOOLS_DIR/bin/generate_appcast" -s "$SPARKLE_PRIVATE_KEY" "$RELEASES_DIR"

cp "$RELEASES_DIR/appcast.xml" "$ROOT_DIR/appcast.xml"
echo "==> appcast.xml mis à jour"
