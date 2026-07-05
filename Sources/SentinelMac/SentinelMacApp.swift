import SwiftUI

@main
struct SentinelMacApp: App {
    @StateObject private var monitor = HealthMonitor()
    @StateObject private var updater = UpdaterViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(updater: updater)
                .environmentObject(monitor)
        } label: {
            // macOS force par défaut les icônes de barre de menu en "template"
            // (monochrome, ignore toute couleur) — .palette est le mode de
            // rendu SF Symbols qui échappe à ce templating automatique et
            // affiche vraiment la couleur voulue.
            Image(systemName: monitor.displaySymbolName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(monitor.displayColor)
        }
        .menuBarExtraStyle(.window)

        Window("Dashboard Sentinel", id: "dashboard") {
            WebView(url: Config.baseURL)
                .frame(minWidth: 900, minHeight: 600)
        }
    }
}
