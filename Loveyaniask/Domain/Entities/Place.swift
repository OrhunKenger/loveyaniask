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

    /// Verilmiş puanların ortalaması (0 = hiç puan yok).
    var averageRating: Double {
        let values = ratings.values.filter { $0 > 0 }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}
