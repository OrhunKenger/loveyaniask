//
//  QuickNote.swift
//  Loveyaniask
//
//  Ana sayfadaki "Hızlı Not": aklınıza geleni hemen yazıp unutmamak için
//  bırakılan serbest, ortak (senkron) bir not.
//

import Foundation

struct QuickNote: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    var authorKey: String   // UserProfile.rawValue
    var createdAt: Date
}
