//
//  PartnerProfile.swift
//  Loveyaniask
//
//  Bir partnerin profili: "hakkımda" + fotoğraf (küçültülmüş, base64 → senkron).
//  İsim/petName sabit olarak UserProfile'dan gelir.
//

import Foundation

struct PartnerProfile: Identifiable, Equatable {
    let userKey: String   // UserProfile.rawValue
    var bio: String
    var photoBase64: String?

    var id: String { userKey }
}
