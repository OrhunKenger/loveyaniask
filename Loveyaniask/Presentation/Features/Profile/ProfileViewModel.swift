//
//  ProfileViewModel.swift
//  Loveyaniask
//
//  Profil sayfası mantığı (Firebase, gerçek zamanlı). Her iki partnerin
//  "hakkımda" + fotoğrafını okur; kendi profilini düzenler.
//  Fotoğraf küçültülüp base64 olarak saklanır → iki cihazda da senkron.
//

import Foundation
import Observation
import UIKit

@Observable
final class ProfileViewModel {
    private(set) var profiles: [String: PartnerProfile] = [:]
    var showingEdit = false

    let currentUser: UserProfile
    private let repository: any ProfileRepository
    private let auth: any AuthService

    init(currentUser: UserProfile, repository: any ProfileRepository, auth: any AuthService) {
        self.currentUser = currentUser
        self.repository = repository
        self.auth = auth
        repository.observeProfiles { [weak self] in self?.profiles = $0 }
    }

    /// Girili kullanıcının şifresini değiştirir. Hata varsa mesajı döner, yoksa nil.
    func changePassword(_ newPassword: String) async -> String? {
        guard newPassword.count >= 6 else { return "Şifre en az 6 karakter olmalı" }
        do {
            try await auth.changePassword(to: newPassword)
            return nil
        } catch {
            return "Şifre değiştirilemedi. Güvenlik için çıkıp tekrar giriş yapıp dene."
        }
    }

    var partner: UserProfile { currentUser.partner }

    func bio(for profile: UserProfile) -> String {
        profiles[profile.rawValue]?.bio ?? ""
    }

    func image(for profile: UserProfile) -> UIImage? {
        guard let b64 = profiles[profile.rawValue]?.photoBase64,
              let data = Data(base64Encoded: b64) else { return nil }
        return UIImage(data: data)
    }

    /// Kendi profilini kaydeder. image nil ise mevcut fotoğraf korunur.
    func saveMyProfile(bio: String, image: UIImage?) {
        let b64 = image.flatMap { Self.downsampledBase64($0) }
        repository.save(
            userKey: currentUser.rawValue,
            bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
            photoBase64: b64
        )
    }

    /// Fotoğrafı ~320px'e küçültüp JPEG base64'e çevirir (senkron için hafif).
    private static func downsampledBase64(_ image: UIImage, maxDimension: CGFloat = 320) -> String? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }
        let scale = min(1, maxDimension / max(size.width, size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.7)?.base64EncodedString()
    }
}
