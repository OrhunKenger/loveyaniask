//
//  HasPasswordUseCase.swift
//  Loveyaniask
//
//  Bir kullanıcının daha önce şifre belirleyip belirlemediğini söyler.
//

import Foundation

struct HasPasswordUseCase {
    private let store: CredentialStore

    init(store: CredentialStore) {
        self.store = store
    }

    func execute(profile: UserProfile) -> Bool {
        store.hasPassword(for: profile)
    }
}
