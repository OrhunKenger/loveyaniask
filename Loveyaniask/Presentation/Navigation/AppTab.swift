//
//  AppTab.swift
//  Loveyaniask
//
//  Alt bardaki sekmeler. Sıra: Gitmek İstediğimiz · Ruh Hali · Ana Sayfa · Takvim · Gittiğimiz.
//  Ana sayfa tam ortada. Yeni sekme eklemek için buraya bir case eklemek yeterli.
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case library
    case wishlist
    case home
    case period
    case places

    var id: Int { rawValue }

    /// Seçili değilken gösterilen ikon.
    var icon: String {
        switch self {
        case .library: return "books.vertical"
        case .wishlist: return "signpost.right"
        case .home: return "house"
        case .places: return "map"
        case .period: return "calendar"
        }
    }

    /// Seçiliyken gösterilen (dolu) ikon.
    var selectedIcon: String {
        switch self {
        case .library: return "books.vertical.fill"
        case .wishlist: return "signpost.right.fill"
        case .home: return "house.fill"
        case .places: return "map.fill"
        case .period: return "calendar"
        }
    }
}
