//
//  AppTab.swift
//  Loveyaniask
//
//  Alt bardaki sekmeler. Sıra: Gitmek İstediğimiz · Ruh Hali · Ana Sayfa · Takvim · Gittiğimiz.
//  Ana sayfa tam ortada. Yeni sekme eklemek için buraya bir case eklemek yeterli.
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case wishlist
    case mood
    case home
    case period
    case places

    var id: Int { rawValue }

    /// Seçili değilken gösterilen ikon.
    var icon: String {
        switch self {
        case .wishlist: return "signpost.right"
        case .mood: return "face.smiling"
        case .home: return "house"
        case .period: return "calendar"
        case .places: return "map"
        }
    }

    /// Seçiliyken gösterilen (dolu) ikon.
    var selectedIcon: String {
        switch self {
        case .wishlist: return "signpost.right.fill"
        case .mood: return "face.smiling.fill"
        case .home: return "house.fill"
        case .period: return "calendar"
        case .places: return "map.fill"
        }
    }
}
