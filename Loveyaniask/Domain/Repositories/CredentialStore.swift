//
//  CredentialStore.swift
//  Loveyaniask
//
//  Her kullanıcının şifresinin güvenli saklanması için Domain sözleşmesi.
//  Şifrenin nasıl saklandığı (Keychain, hash vb.) Data katmanının işi.
//

import Foundation

protocol CredentialStore {
    func hasPassword(for profile: UserProfile) -> Bool
    func setPassword(_ password: String, for profile: UserProfile)
    func verify(_ password: String, for profile: UserProfile) -> Bool
}
