import Foundation
import Security

public enum KeychainHelper {
    private static let serviceName = "ch.algourmand.app"
    private static let tokenAccount = "authToken"
    private static let fallbackKey = "algourmand_keychain_fallback_authToken"

    @discardableResult
    public static func saveToken(_ token: String) -> Bool {
        UserDefaults.standard.set(token, forKey: fallbackKey)

        guard let data = token.data(using: .utf8) else { return false }

        deleteFromKeychainOnly()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecDuplicateItem
    }

    public static func readToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data, let token = String(data: data, encoding: .utf8) {
            return token
        }

        return UserDefaults.standard.string(forKey: fallbackKey)
    }

    @discardableResult
    public static func deleteToken() -> Bool {
        UserDefaults.standard.removeObject(forKey: fallbackKey)
        return deleteFromKeychainOnly()
    }

    @discardableResult
    private static func deleteFromKeychainOnly() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: tokenAccount
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
