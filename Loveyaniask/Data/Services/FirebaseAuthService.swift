//
//  FirebaseAuthService.swift
//  Loveyaniask
//
//  AuthService'in Firebase Authentication implementasyonu.
//  Oturum, Firebase SDK tarafından otomatik ve kalıcı olarak (Keychain'de)
//  saklanır → bir cihazda bir kez giriş yapılınca açılışta hep girili gelir.
//
//  Kurulum (Firebase konsolu): Authentication → Email/Password aç,
//  ve UserProfile.authEmail'deki iki e-postayla birer hesap oluştur.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthService: AuthService {
    var currentUser: UserProfile? {
        guard let email = Auth.auth().currentUser?.email else { return nil }
        return UserProfile(authEmail: email)
    }

    func signIn(profile: UserProfile, password: String) async throws {
        try await Auth.auth().signIn(withEmail: profile.authEmail, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
