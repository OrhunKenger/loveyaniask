//
//  AppTab.swift
//  Loveyaniask
//
//  Alt bardaki sekmeler. Sıra: Ruh Hali · Ana Sayfa · Takvim · Mekanlar.
//  Yeni sekme eklemek için buraya bir case eklemek yeterli.
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case mood
    case home
    case period
    case places

    var id: Int { rawValue }

    /// Seçili değilken gösterilen ikon.
    var icon: String {
        switch self {
        case .mood: return "face.smiling"
        case .home: return "house"
        case .period: return "calendar"
        case .places: return "map"
        }
    }

    /// Seçiliyken gösterilen (dolu) ikon.
    var selectedIcon: String {
        switch self {
        case .mood: return "face.smiling.fill"
        case .home: return "house.fill"
        case .period: return "calendar"
        case .places: return "map.fill"
        }
    }
}
