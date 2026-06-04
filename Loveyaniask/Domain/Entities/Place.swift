//
//  Place.swift
//  Loveyaniask
//
//  Gidilen bir mekan. Puanı iki kişi de verir (ratings sözlüğü),
//  pin rengi ortalamaya göre. Konum saf Double — Domain harita-bağımsız.
//

import Foundation

struct Place: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var ratings: [String: Int]   // UserProfile.rawValue -> 1...5
    var note: String
    var dateVisited: Date
    var photoFileName: String?
    /// true = gittiğimiz, false = gitmek istediğimiz (hayal listesi).
    var visited: Bool = true

    /// Verilmiş puanların ortalaması (0 = hiç puan yok).
    var averageRating: Double {
        let values = ratings.values.filter { $0 > 0 }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}

// Eski kayıtlarda `visited` alanı yok — onları "gittiğimiz" (true) say.
extension Place {
    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, ratings, note, dateVisited, photoFileName, visited
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        latitude = try c.decode(Double.self, forKey: .latitude)
        longitude = try c.decode(Double.self, forKey: .longitude)
        ratings = try c.decode([String: Int].self, forKey: .ratings)
        note = try c.decode(String.self, forKey: .note)
        dateVisited = try c.decode(Date.self, forKey: .dateVisited)
        photoFileName = try c.decodeIfPresent(String.self, forKey: .photoFileName)
        visited = try c.decodeIfPresent(Bool.self, forKey: .visited) ?? true
    }
}
