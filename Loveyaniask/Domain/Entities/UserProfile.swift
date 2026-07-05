//
//  UserProfile.swift
//  Loveyaniask
//
//  Uygulamanın iki kullanıcısı. Giriş ekranında seçilen kişi "Ben" olur.
//

import Foundation

enum UserProfile: String, CaseIterable, Identifiable, Codable {
    case orhun
    case sevval

    var id: String { rawValue }

    /// Firebase Authentication için bu profile karşılık gelen sabit e-posta.
    /// Bu iki hesap Firebase konsolundan (Email/Password) oluşturulur.
    var authEmail: String {
        switch self {
        case .orhun: return "orhunkenger@loveyaniask.com"
        case .sevval: return "sevvalkenger@loveyaniask.com"
        }
    }

    /// Firebase oturumu geri yüklenirken e-postadan profile geri eşleme.
    init?(authEmail email: String) {
        let lower = email.lowercased()
        if lower == UserProfile.orhun.authEmail { self = .orhun }
        else if lower == UserProfile.sevval.authEmail { self = .sevval }
        else { return nil }
    }

    var fullName: String {
        switch self {
        case .orhun: return "Orhun Sina"
        case .sevval: return "Şevval Ay"
        }
    }

    var firstName: String {
        switch self {
        case .orhun: return "Orhun"
        case .sevval: return "Şevval"
        }
    }

    var initials: String {
        switch self {
        case .orhun: return "OS"
        case .sevval: return "ŞA"
        }
    }

    /// Diğer kişi (partner).
    var partner: UserProfile {
        switch self {
        case .orhun: return .sevval
        case .sevval: return .orhun
        }
    }

    /// Sevgilisinin ona seslendiği takma ad.
    var petName: String {
        switch self {
        case .orhun: return "Orhim"
        case .sevval: return "Şevvalim"
        }
    }
}
