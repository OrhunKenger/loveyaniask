//
//  LibraryItem.swift
//  Loveyaniask
//
//  Dijital kütüphanedeki bir öğe: film, dizi veya kitap.
//  İkili puan (ratings), durum (izleyeceğiz/devam/bitti), poster.
//

import Foundation

enum LibraryKind: String, CaseIterable, Identifiable, Codable {
    case film
    case dizi
    case kitap

    var id: String { rawValue }

    var label: String {
        switch self {
        case .film: return "Film"
        case .dizi: return "Dizi"
        case .kitap: return "Kitap"
        }
    }

    var emoji: String {
        switch self {
        case .film: return "🎬"
        case .dizi: return "📺"
        case .kitap: return "📚"
        }
    }
}

enum LibraryStatus: String, CaseIterable, Identifiable, Codable {
    case want        // izleyeceğiz / okuyacağız
    case inProgress  // devam ediyor
    case done        // bitti

    var id: String { rawValue }

    func label(for kind: LibraryKind) -> String {
        switch self {
        case .want: return kind == .kitap ? "Okuyacağız" : "İzleyeceğiz"
        case .inProgress: return kind == .kitap ? "Okuyoruz" : "İzliyoruz"
        case .done: return "Bitti ✓"
        }
    }
}

struct LibraryItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var kind: LibraryKind
    var status: LibraryStatus
    var posterURL: String?
    var overview: String
    var ratings: [String: Int]   // UserProfile.rawValue -> 1...5
    var note: String
    var addedBy: String
    var addedAt: Date

    var averageRating: Double {
        let values = ratings.values.filter { $0 > 0 }
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
    }
}
