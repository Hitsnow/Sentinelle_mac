import SwiftUI
import WebKit

/// Enrobage minimal de WKWebView : charge le dashboard Sentinel existant tel
/// quel (JS/CSS servis par l'orchestrateur, cache-busting déjà géré côté
/// serveur — cf. `app/api/dashboard.py::_asset_version()`). Aucune logique de
/// rendu dupliquée ici, l'app ne fait qu'afficher la même page que le
/// navigateur.
struct WebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
