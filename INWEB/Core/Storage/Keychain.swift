import Foundation
import Security

/// Thin wrapper around iOS Keychain Services for storing the bearer token
/// securely. Never use UserDefaults for secrets on iOS — they end up in
/// the app's plist, which is world-readable on a jailbroken device.
enum Keychain {

    private static let service = "app.inweb.ios"

    static func set(_ value: String, for key: String) {
        // Delete any existing item first — Keychain has no "upsert".
        remove(key: key)
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecValueData:   data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    static func get(_ key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var out: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &out)
        guard status == errSecSuccess, let data = out as? Data,
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }

    static func remove(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
