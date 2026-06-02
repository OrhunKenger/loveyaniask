//
//  Place.swift
//  Loveyaniask
//
//  Gidilen bir mekan. Konum (enlem/boylam) saf Double olarak tutulur
//  ki Domain hiçbir harita framework'üne bağımlı olmasın.
//

import Foundation

struct Place: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var rating: Int          // 0...5 yıldız
    var note: String
    var dateVisited: Date
    var photoFileName: String?
}
