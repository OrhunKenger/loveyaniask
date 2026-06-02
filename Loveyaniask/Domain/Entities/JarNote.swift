//
//  JarNote.swift
//  Loveyaniask
//
//  Kavanoza atılan bir not — birbiriniz hakkında düşündükleriniz.
//

import Foundation

struct JarNote: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    var authorKey: String   // UserProfile.rawValue
    var createdAt: Date
}
