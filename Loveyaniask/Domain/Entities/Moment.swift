//
//  Moment.swift
//  Loveyaniask
//
//  Akış'taki tek bir an: fotoğraf veya video, kalıcı, tarih ve paylaşan kişiyle.
//

import Foundation

enum MomentMediaType: String, Codable {
    case photo
    case video
}

struct Moment: Identifiable, Equatable {
    let id: String
    let author: UserProfile
    let mediaType: MomentMediaType
    let storagePath: String
    let createdAt: Date
    let dayKey: String
    /// Partner tepki verip "bunu şu tarihte tekrar göster" dediyse dolu.
    var resurfaceAt: Date?
    /// Ken bu anı kendiliğinden tekrar gösterdiyse bıraktığı kısa yorum.
    var kenComment: String?
}
