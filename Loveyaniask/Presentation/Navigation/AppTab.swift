//
//  AppTab.swift
//  Loveyaniask
//
//  Alt bardaki sekmeler. Sıra: Akış · Ruh Hali · Ana Sayfa · Takvim · Gittiğimiz.
//  Ana sayfa tam ortada. Yeni sekme eklemek için buraya bir case eklemek yeterli.
//
//  NOT: "Gitmek İstediğimiz" (wishlist) sekmesi buradan kaldırıldı, yerine Akış
//  geldi. Wishlist verisi hâlâ Firebase'de duruyor (PlacesViewModel üzerinden,
//  PlacesView ile paylaşılan aynı repository) — sadece ayrı bir sekme olarak
//  gösterilmiyor. Haritanın olduğu (Gittiğimiz) sayfa güncellenince oraya taşınacak.
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case library
    case akis
    case home
    case period
    case places

    var id: Int { rawValue }

    /// Seçili değilken gösterilen ikon.
    var icon: String {
        switch self {
        case .library: return "books.vertical"
        case .akis: return "rectangle.stack"
        case .home: return "house"
        case .places: return "map"
        case .period: return "calendar"
        }
    }

    /// Seçiliyken gösterilen (dolu) ikon.
    var selectedIcon: String {
        switch self {
        case .library: return "books.vertical.fill"
        case .akis: return "rectangle.stack.fill"
        case .home: return "house.fill"
        case .places: return "map.fill"
        case .period: return "calendar"
        }
    }
}
