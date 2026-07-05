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
            Image(systemName: monitor.overall.symbolName)
                .foregroundStyle(monitor.overall.tintColor)
        }
        .menuBarExtraStyle(.window)

        Window("Dashboard Sentinel", id: "dashboard") {
            WebView(url: Config.baseURL)
                .frame(minWidth: 900, minHeight: 600)
        }
    }
}
