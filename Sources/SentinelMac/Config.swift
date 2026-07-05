import Foundation

/// Point d'entrée unique de configuration. Pas de fichier de settings pour
/// l'instant : une seule instance Sentinel (fsociety), un seul utilisateur.
/// IP tailscale de fsociety (confirmée joignable depuis le Mac de Pierre,
/// `docker exec tailscale tailscale ip -4` sur fsociety).
enum Config {
    static let baseURL = URL(string: "http://100.119.170.12:8099")!
    static let servicesURL = baseURL.appendingPathComponent("services")
    static let eventsURL = baseURL.appendingPathComponent("events")
}
