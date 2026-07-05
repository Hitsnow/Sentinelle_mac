import Sparkle

/// Enrobage minimal du contrôleur Sparkle standard. `startingUpdater: true`
/// démarre la vérification périodique en tâche de fond dès le lancement
/// (fréquence par défaut Sparkle, réglable via `SUScheduledCheckInterval`
/// dans Info.plist). Première vérification : Sparkle demande une fois à
/// l'utilisateur s'il autorise les mises à jour automatiques (dialogue
/// standard macOS, comportement Sparkle par défaut, pas quelque chose
/// qu'on désactive).
final class UpdaterViewModel: ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
