import Foundation

// MARK: - /api/inweb/ping
struct PingResponse: Decodable {
    let pong: Bool
    let app: String
    let version: String
    let apiVersion: Int
}

// MARK: - /api/inweb/status
struct StatusResponse: Decodable {
    let timestamp: Int64
    let services:  Services
    let device:    Device

    struct Services: Decodable {
        let engine: String
        let httpPort: Int
        let mysqlPort: Int
        let httpsEnabled: Bool
        let liveReloadEnabled: Bool
        let dnsServerEnabled: Bool
    }
    struct Device: Decodable {
        let localIp: String?
        let ssid: String?
        let cpu: Int
        let ramUsed: Int64
        let ramTotal: Int64
        let storageFree: Int64
        let storageTotal: Int64
    }
}

// MARK: - /api/inweb/prefs
struct PrefsResponse: Decodable {
    var webServer: String
    var httpPort: Int
    var bindLan: Bool
    var mysqlEnabled: Bool
    var mysqlPort: Int
    var httpsEnabled: Bool
    var httpsPort: Int
    var liveReloadEnabled: Bool
    var dnsServerEnabled: Bool
    var dnsServerPort: Int
    var themeMode: String
}

// MARK: - Virtual hosts
struct VhostsResponse: Decodable { let vhosts: [Vhost] }

struct Vhost: Decodable, Identifiable, Hashable {
    let id: String
    let serverName: String
    let documentRoot: String
    let phpMode: String
    let enabled: Bool
    let label: String
}

/// Payload we send to POST /vhosts (identical to Vhost minus computed props).
struct VHostPayload {
    var id: String?
    var serverName: String
    var documentRoot: String
    var phpMode: String  = "AUTO"
    var enabled: Bool    = true
    var label: String    = ""

    func asDictionary() -> [String: Any] {
        var d: [String: Any] = [
            "serverName":   serverName,
            "documentRoot": documentRoot,
            "phpMode":      phpMode,
            "enabled":      enabled,
            "label":        label,
        ]
        if let id = id { d["id"] = id }
        return d
    }
}

// MARK: - DNS host entries
struct HostsResponse: Decodable { let hosts: [HostEntry] }

struct HostEntry: Decodable, Identifiable, Hashable {
    let id: String
    let hostname: String
    let ip: String
    let enabled: Bool
    let note: String
}

struct HostPayload {
    var id: String?
    var hostname: String
    var ip: String
    var enabled: Bool = true
    var note: String  = ""

    func asDictionary() -> [String: Any] {
        var d: [String: Any] = [
            "hostname": hostname, "ip": ip,
            "enabled":  enabled,  "note": note,
        ]
        if let id = id { d["id"] = id }
        return d
    }
}

// MARK: - Logs
struct LogsResponse: Decodable {
    let file:    String
    let size:    Int64
    let content: String
}

// MARK: - Prayer times (matches PrayerTimeCalculator's enum, lowercased)
struct PrayerTimesResponse: Decodable {
    let latitude:  Double?
    let longitude: Double?
    let timings:   Timings

    struct Timings: Decodable {
        let fajr:    Int64
        let sunrise: Int64
        let dhuhr:   Int64
        let asr:     Int64
        let maghrib: Int64
        let isha:    Int64
    }
}
