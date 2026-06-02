//
//  VerifyPasswordUseCase.swift
//  Loveyaniask
//
//  Girilen şifrenin doğru olup olmadığını kontrol eder.
//

import Foundation

struct VerifyPasswordUseCase {
    private let store: CredentialStore

    init(store: CredentialStore) {
        self.store = store
    }

    func execute(_ password: String, profile: UserProfile) -> Bool {
        store.verify(password, for: profile)
    }
}
