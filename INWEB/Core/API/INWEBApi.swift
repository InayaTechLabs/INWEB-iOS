import Foundation

/// Typed client for the REST endpoints exposed by the Android app's
/// `InwebApiServer.kt`. Every method is `async throws` — call sites use
/// `await` inside `.task {}` blocks so SwiftUI handles cancellation for us.
///
/// The endpoint set MUST stay in sync with `ApiRouter.kt`. Whenever a new
/// endpoint is added there, mirror it here.
final class INWEBApi {

    // MARK: - Errors
    enum APIError: LocalizedError {
        case badURL, unauthorized, http(Int), decode, offline

        var errorDescription: String? {
            switch self {
            case .badURL:       return "Bad URL — check the host you entered."
            case .unauthorized: return "Invalid bearer token."
            case .http(let c):  return "Server returned HTTP \(c)."
            case .decode:       return "Unexpected response from server."
            case .offline:      return "Could not reach INWEB — is Wi-Fi on?"
            }
        }
    }

    private unowned let session: Session

    init(session: Session) { self.session = session }

    // MARK: - Endpoints (mirroring ApiRouter.kt)

    func ping() async throws -> PingResponse {
        try await get("/api/inweb/ping")
    }

    func status() async throws -> StatusResponse {
        try await get("/api/inweb/status")
    }

    func prefs() async throws -> PrefsResponse {
        try await get("/api/inweb/prefs")
    }

    func updatePrefs(_ patch: [String: Any]) async throws {
        try await send(method: "PUT", path: "/api/inweb/prefs", jsonBody: patch)
    }

    func vhosts() async throws -> VhostsResponse {
        try await get("/api/inweb/vhosts")
    }

    func upsertVhost(_ vhost: VHostPayload) async throws {
        try await send(method: "POST", path: "/api/inweb/vhosts",
                       jsonBody: vhost.asDictionary())
    }

    func deleteVhost(id: String) async throws {
        try await send(method: "DELETE", path: "/api/inweb/vhosts/\(id)")
    }

    func hosts() async throws -> HostsResponse {
        try await get("/api/inweb/hosts")
    }

    func upsertHost(_ host: HostPayload) async throws {
        try await send(method: "POST", path: "/api/inweb/hosts",
                       jsonBody: host.asDictionary())
    }

    func deleteHost(id: String) async throws {
        try await send(method: "DELETE", path: "/api/inweb/hosts/\(id)")
    }

    func logs(file: String, bytes: Int = 16_384) async throws -> LogsResponse {
        try await get("/api/inweb/logs?file=\(file)&bytes=\(bytes)")
    }

    /// service = "nginx" | "php-fpm" | "mysql"; op = .start / .stop.
    enum ServiceOp: String { case start, stop }
    func serviceControl(service: String, op: ServiceOp) async throws {
        try await send(method: "POST",
                       path: "/api/inweb/service/\(op.rawValue)",
                       jsonBody: ["service": service])
    }

    func prayerTimes(lat: Double, lng: Double) async throws -> PrayerTimesResponse {
        try await get("/api/inweb/prayer-times?lat=\(lat)&lng=\(lng)")
    }

    // MARK: - Low-level transport

    private func get<T: Decodable>(_ path: String) async throws -> T {
        try await request(method: "GET", path: path, body: nil)
    }

    /// Discarding variant for endpoints where we don't need the response body.
    private func send(method: String, path: String, jsonBody: [String: Any]? = nil) async throws {
        _ = try await request(method: method, path: path, body: jsonBody,
                              decodeAs: EmptyResponse.self)
    }

    private func request<T: Decodable>(
        method: String, path: String,
        body: [String: Any]? = nil,
        decodeAs: T.Type = T.self
    ) async throws -> T {
        guard var url = URL(string: session.host) else { throw APIError.badURL }
        url.append(path: path)   // uses the correct URL joining

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(session.token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json",        forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 10

        if let body = body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError.offline
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.decode }
        switch http.statusCode {
        case 200...299:
            if T.self == EmptyResponse.self { return EmptyResponse() as! T }
            do { return try JSONDecoder.inweb.decode(T.self, from: data) }
            catch { throw APIError.decode }
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.http(http.statusCode)
        }
    }
}

// MARK: - URL helper (backport of `.append(path:)` for iOS 15)
private extension URL {
    mutating func append(path: String) {
        if #available(iOS 16.0, *) {
            self.append(path: path)
        } else {
            self = self.appendingPathComponent(path)
        }
    }
}

/// Empty response marker — used with `send()` to keep the generic tidy.
struct EmptyResponse: Decodable {}

extension JSONDecoder {
    /// A shared decoder tuned to Android's JSON output (snake-lite / camel).
    static let inweb: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()
}
