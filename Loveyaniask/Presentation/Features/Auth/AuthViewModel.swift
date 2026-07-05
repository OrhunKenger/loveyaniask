//
//  AuthViewModel.swift
//  Loveyaniask
//
//  Giriş akışının mantığı: splash → profil seçimi → şifre → Firebase girişi.
//  Oturum Firebase'de kalıcı olduğundan, daha önce giriş yapılmış bir cihazda
//  açılışta `currentUser` doğrudan dolu gelir ve giriş ekranları atlanır.
//

import Foundation
import Observation

enum AuthStage: Equatable {
    case splash
    case selectProfile
    case password
}

@Observable
final class AuthViewModel {
    // Açılış splash'i artık LaunchContainer'da (logo büyüyerek açılır), bu yüzden
    // doğrudan profil seçiminden başlıyoruz — eski uygulama-içi splash atlandı.
    var stage: AuthStage = .selectProfile
    var selectedProfile: UserProfile?
    private(set) var currentUser: UserProfile?
    var errorMessage: String?
    var isSubmitting = false

    private let auth: any AuthService

    init(auth: any AuthService) {
        self.auth = auth
        // Kalıcı oturum varsa açılışta doğrudan girili başla.
        self.currentUser = auth.currentUser
    }

    var isAuthenticated: Bool { currentUser != nil }

    func finishSplash() {
        // Splash bittiğinde oturum hâlâ açıksa (geç gelen durum) doğrudan gir.
        if currentUser != nil { return }
        stage = .selectProfile
    }

    func select(_ profile: UserProfile) {
        selectedProfile = profile
        errorMessage = nil
        stage = .password
    }

    func submitPassword(_ password: String) async {
        guard let profile = selectedProfile else { return }
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await auth.signIn(profile: profile, password: password)
            currentUser = profile
        } catch {
            // Geçici teşhis: gerçek Firebase hatasını göster.
            let ns = error as NSError
            errorMessage = "\(error.localizedDescription) [\(ns.domain) \(ns.code)]"
        }
    }

    func signOut() {
        try? auth.signOut()
        currentUser = nil
        selectedProfile = nil
        errorMessage = nil
        stage = .selectProfile
    }

    func backToProfiles() {
        selectedProfile = nil
        errorMessage = nil
        stage = .selectProfile
    }
}
