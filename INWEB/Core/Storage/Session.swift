import Foundation
import Combine

/// The user's connection to a single Android INWEB instance.
///
/// Stores host (in UserDefaults — not sensitive) and bearer token (in
/// Keychain). Exposed as an `ObservableObject` so any SwiftUI view can
/// react when the user logs in or out.
final class Session: ObservableObject {

    // MARK: - Public reactive state
    @Published private(set) var host:  String = ""
    @Published private(set) var token: String = ""

    var isConfigured: Bool { !host.isEmpty && !token.isEmpty }

    /// The client every screen uses to talk to the Android instance.
    /// Reconfigured whenever the connection changes.
    private(set) lazy var api: INWEBApi = INWEBApi(session: self)

    // MARK: - Init
    init() {
        self.host  = UserDefaults.standard.string(forKey: Self.kHost) ?? ""
        self.token = Keychain.get(Self.kToken) ?? ""
    }

    // MARK: - Login / logout
    func login(host: String, token: String) {
        let normalisedHost = normaliseHost(host)
        self.host  = normalisedHost
        self.token = token
        UserDefaults.standard.set(normalisedHost, forKey: Self.kHost)
        Keychain.set(token, for: Self.kToken)
    }

    func logout() {
        host = ""; token = ""
        UserDefaults.standard.removeObject(forKey: Self.kHost)
        Keychain.remove(key: Self.kToken)
    }

    // MARK: - Helpers
    /// Strip trailing slashes, add http:// if the user forgot it.
    private func normaliseHost(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespaces)
        while s.hasSuffix("/") { s.removeLast() }
        if !s.lowercased().hasPrefix("http://") &&
           !s.lowercased().hasPrefix("https://") {
            s = "http://" + s
        }
        return s
    }

    private static let kHost  = "inweb.session.host"
    private static let kToken = "inweb.session.token"
}
