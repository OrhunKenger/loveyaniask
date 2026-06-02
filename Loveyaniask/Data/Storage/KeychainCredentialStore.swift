//
//  KeychainCredentialStore.swift
//  Loveyaniask
//
//  CredentialStore'un Keychain implementasyonu.
//  Şifre düz metin DEĞİL, SHA-256 hash'i olarak saklanır.
//

import Foundation
import Security
import CryptoKit

final class KeychainCredentialStore: CredentialStore {
    private let service = "com.loveyaniask.credentials"

    private func account(for profile: UserProfile) -> String {
        "password.\(profile.rawValue)"
    }

    private func hash(_ password: String) -> Data {
        let digest = SHA256.hash(data: Data(password.utf8))
        return Data(digest)
    }

    // MARK: - CredentialStore

    func hasPassword(for profile: UserProfile) -> Bool {
        readData(account: account(for: profile)) != nil
    }

    func setPassword(_ password: String, for profile: UserProfile) {
        write(data: hash(password), account: account(for: profile))
    }

    func verify(_ password: String, for profile: UserProfile) -> Bool {
        guard let stored = readData(account: account(for: profile)) else { return false }
        return stored == hash(password)
    }

    // MARK: - Keychain yardımcıları

    private func write(data: Data, account: String) {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(baseQuery as CFDictionary)

        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func readData(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
}
