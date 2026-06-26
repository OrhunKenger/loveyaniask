//
//  AuthService.swift
//  Loveyaniask
//
//  Kimlik doğrulama için Domain sözleşmesi.
//  Oturumun nasıl tutulduğu (Firebase, Keychain vb.) Data katmanının işi.
//

import Foundation

protocol AuthService {
    /// O an girili kullanıcı. Oturum kalıcıysa uygulama açılışında dolu gelir
    /// (cihazda bir kez giriş yapılınca hep girili kalır).
    var currentUser: UserProfile? { get }

    /// Seçilen profil + şifre ile giriş yapar. Başarısızsa hata fırlatır.
    func signIn(profile: UserProfile, password: String) async throws

    /// Oturumu kapatır (cihazdaki kalıcı oturumu siler).
    func signOut() throws
}
