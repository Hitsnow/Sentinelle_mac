# Sentinel Mac

App menu bar macOS pour [Sentinel](https://github.com/) (supervision homelab, orchestrateur sur `fsociety`). Icône colorée selon la santé globale (SSE `/events`), popover de résumé, fenêtre avec le dashboard web existant (WKWebView).

## Architecture — deux mécanismes de mise à jour distincts

1. **Contenu du dashboard** (JS/CSS/API côté Sentinel) : automatique, zéro action nécessaire. L'app charge la page web existante à chaque ouverture — toute évolution du dashboard est visible immédiatement, sans nouvelle version de l'app.
2. **La coquille native elle-même** (ce dépôt) : mise à jour via [Sparkle](https://sparkle-project.org/), déclenchée par un tag `v*` qui lance la CI (`.github/workflows/release.yml`, runner `macos-latest` — ce projet ne peut pas être compilé sur Linux).

Pas de compte Apple Developer : signature ad-hoc (`codesign --sign -`), pas de notarisation. La toute première installation nécessite un clic droit → "Ouvrir" (Gatekeeper). Les mises à jour suivantes via Sparkle devraient rester fluides mais ce n'est pas garanti sans notarisation.

## Mise en route (étapes manuelles, une seule fois)

1. **GitHub Pages** : Settings → Pages → Source = "Deploy from a branch" → branche `main`, dossier `/ (root)`. Sert `appcast.xml` à l'URL `https://hitsnow.github.io/Sentinelle_mac/appcast.xml` (déjà référencée dans `Resources/Info.plist`).
2. **Clés Sparkle** : lancer le workflow `Générer les clés Sparkle` (onglet Actions → "Générer les clés Sparkle (une seule fois)" → Run workflow). Copier immédiatement les deux clés affichées dans les logs vers Settings → Secrets and variables → Actions :
   - `SPARKLE_PRIVATE_KEY`
   - `SPARKLE_PUBLIC_KEY`
3. **Premier tag** : `git tag v0.1.0 && git push origin v0.1.0` déclenche la CI, qui construit le `.dmg`, publie une GitHub Release et met à jour `appcast.xml`.
4. **Première installation** : télécharger le `.dmg` depuis la Release, ouvrir, glisser dans `/Applications`, clic droit → Ouvrir (Gatekeeper, une seule fois).

Les mises à jour suivantes (nouveaux tags `v*`) devraient s'installer seules via Sparkle, sans repasser par ces étapes.

## Développement local

Nécessite Xcode (macOS uniquement) :

```sh
swift build
swift run
```

## Structure

- `Sources/SentinelMac/` : code Swift (SwiftUI + AppKit minimal + Sparkle).
- `Resources/Info.plist` : métadonnées du bundle, config Sparkle (`SUFeedURL`, `SUPublicEDKey`).
- `scripts/` : assemblage du `.app`, packaging `.dmg`, signature Sparkle + régénération d'`appcast.xml`.
- `releases/` : archive de tous les `.dmg` publiés (nécessaire à `generate_appcast`, qui reconstruit l'appcast complet à partir de cet historique à chaque release).
- `.github/workflows/release.yml` : CI de release (sur tag `v*`).
- `.github/workflows/generate-keys.yml` : bootstrap unique des clés Sparkle.

## Config Sentinel

L'URL du serveur est en dur dans `Sources/SentinelMac/Config.swift` (IP tailscale de fsociety) — un seul utilisateur, une seule instance, pas de fichier de settings pour l'instant.
