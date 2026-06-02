//
//  AuthViewModel.swift
//  Loveyaniask
//
//  Giriş akışının mantığı: splash → profil seçimi → şifre (oluştur/gir) → giriş.
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
    var stage: AuthStage = .splash
    var selectedProfile: UserProfile?
    private(set) var currentUser: UserProfile?
    var errorMessage: String?

    var isAuthenticated: Bool { currentUser != nil }

    private let hasPassword: HasPasswordUseCase
    private let setPassword: SetPasswordUseCase
    private let verifyPassword: VerifyPasswordUseCase

    init(
        hasPassword: HasPasswordUseCase,
        setPassword: SetPasswordUseCase,
        verifyPassword: VerifyPasswordUseCase
    ) {
        self.hasPassword = hasPassword
        self.setPassword = setPassword
        self.verifyPassword = verifyPassword
    }

    func finishSplash() {
        stage = .selectProfile
    }

    func select(_ profile: UserProfile) {
        selectedProfile = profile
        errorMessage = nil
        stage = .password
    }

    func isCreatingPassword() -> Bool {
        guard let profile = selectedProfile else { return false }
        return !hasPassword.execute(profile: profile)
    }

    func createPassword(_ password: String, confirm: String) {
        guard let profile = selectedProfile else { return }
        guard password.count >= 4 else {
            errorMessage = "Şifre en az 4 karakter olmalı"
            return
        }
        guard password == confirm else {
            errorMessage = "Şifreler eşleşmiyor"
            return
        }
        setPassword.execute(password, profile: profile)
        errorMessage = nil
        currentUser = profile
    }

    func submitPassword(_ password: String) {
        guard let profile = selectedProfile else { return }
        if verifyPassword.execute(password, profile: profile) {
            errorMessage = nil
            currentUser = profile
        } else {
            errorMessage = "Şifre yanlış, tekrar dene"
        }
    }

    func backToProfiles() {
        selectedProfile = nil
        errorMessage = nil
        stage = .selectProfile
    }
}
