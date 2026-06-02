//
//  SetPasswordUseCase.swift
//  Loveyaniask
//
//  Bir kullanıcı için şifre belirler (ilk açılış).
//

import Foundation

struct SetPasswordUseCase {
    private let store: CredentialStore

    init(store: CredentialStore) {
        self.store = store
    }

    func execute(_ password: String, profile: UserProfile) {
        store.setPassword(password, for: profile)
    }
}
