//
//  ProfileRepository.swift
//  Loveyaniask
//
//  Profil veri sınırı (Domain boundary). Gerçek zamanlı dinleme + yazma.
//

import Foundation

protocol ProfileRepository {
    /// Tüm profilleri canlı dinler (userKey → PartnerProfile).
    func observeProfiles(_ onChange: @escaping ([String: PartnerProfile]) -> Void)
    /// Bir profili kaydeder. photoBase64 nil ise mevcut fotoğraf korunur.
    func save(userKey: String, bio: String, photoBase64: String?)
    /// Dinleyiciyi bırak.
    func stop()
}
