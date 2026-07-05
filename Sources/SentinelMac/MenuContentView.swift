import SwiftUI

struct MenuContentView: View {
    @EnvironmentObject private var monitor: HealthMonitor
    @Environment(\.openWindow) private var openWindow
    @ObservedObject var updater: UpdaterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(summaryText, systemImage: monitor.overall.symbolName)
                .foregroundStyle(monitor.overall.tintColor)
                .font(.headline)

            Text(monitor.connected ? "Connecté" : "Déconnecté")
                .font(.caption)
                .foregroundStyle(.secondary)

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
        }
        .padding(12)
        .frame(width: 220)
    }

    private var summaryText: String {
        switch monitor.overall {
        case .healthy: return "Tout va bien"
        case .degraded: return "\(monitor.degradedCount) service(s) dégradé(s)"
        case .down: return "\(monitor.downCount) service(s) en panne"
        case .unknown: return "État inconnu"
        }
    }
}
