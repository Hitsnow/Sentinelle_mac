import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var monitor: HealthMonitor
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var updater: UpdaterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(summaryText, systemImage: monitor.displaySymbolName)
                .foregroundStyle(monitor.displayColor)
                .font(.headline)

            Divider()

            Button("Ouvrir le dashboard") {
                openWindow(id: "dashboard")
            }

            Button("Vérifier les mises à jour…") {
                updater.checkForUpdates()
            }

            Divider()

            Button("Quitter Sentinel") {
                NSApplication.shared.terminate(nil)
            }

            Divider()

            Text("Sentinel \(appVersion)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .frame(width: 220)
    }

    private var summaryText: String {
        guard monitor.connected else { return "Déconnecté (dernier état affiché)" }
        switch monitor.overall {
        case .healthy: return "Tout va bien"
        case .degraded: return "\(monitor.degradedCount) service(s) dégradé(s)"
        case .down: return "\(monitor.downCount) service(s) en panne"
        case .unknown: return "État inconnu"
        }
    }

    /// `CFBundleShortVersionString` (ex. "0.1.0"), injecté par
    /// `scripts/build_app_bundle.sh` à partir du tag git lors des builds
    /// publiés. En dev local (`swift run`), le bundle n'a pas d'Info.plist
    /// avec la vraie version -> "dev" plutôt qu'un champ vide/trompeur.
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }
}
