import Foundation

/// Lecteur SSE minimal (Foundation n'a pas d'EventSource natif côté macOS).
/// Reproduit le comportement du navigateur utilisé par `dashboard.js`
/// (`new EventSource("/events")`) : reconnexion automatique après une
/// coupure, un délai fixe entre essais (le navigateur varie ce délai, on
/// simplifie avec une valeur fixe raisonnable).
struct SSEEvent {
    let event: String
    let data: String
}

actor SSEClient {
    private let url: URL
    private let reconnectDelaySeconds: UInt64 = 3

    init(url: URL) {
        self.url = url
    }

    /// Boucle infinie : appelle `onEvent` pour chaque événement reçu et
    /// `onConnectionChange` à chaque changement d'état de connexion. Ne
    /// retourne jamais (à lancer dans une Task dédiée, annulée à la
    /// fermeture de l'app).
    func run(onEvent: @escaping (SSEEvent) -> Void, onConnectionChange: @escaping (Bool) -> Void) async {
        while !Task.isCancelled {
            do {
                var request = URLRequest(url: url)
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                request.timeoutInterval = 3600

                let (bytes, response) = try await URLSession.shared.bytes(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                onConnectionChange(true)

                var currentEvent = "message"
                var dataLines: [String] = []

                for try await line in bytes.lines {
                    if Task.isCancelled { return }
                    if line.isEmpty {
                        if !dataLines.isEmpty {
                            onEvent(SSEEvent(event: currentEvent, data: dataLines.joined(separator: "\n")))
                        }
                        currentEvent = "message"
                        dataLines = []
                        continue
                    }
                    if line.hasPrefix("event:") {
                        currentEvent = line.dropFirst("event:".count).trimmingCharacters(in: .whitespaces)
                    } else if line.hasPrefix("data:") {
                        dataLines.append(line.dropFirst("data:".count).trimmingCharacters(in: .whitespaces))
                    }
                }
                onConnectionChange(false)
            } catch {
                onConnectionChange(false)
            }
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: reconnectDelaySeconds * 1_000_000_000)
        }
    }
}
