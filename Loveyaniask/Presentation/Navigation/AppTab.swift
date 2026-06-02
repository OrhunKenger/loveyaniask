//
//  AppTab.swift
//  Loveyaniask
//
//  Alt bardaki sekmeler. Yeni sekme eklemek için buraya bir case eklemek yeterli.
//

import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case period

    var id: Int { rawValue }

    /// Seçili değilken gösterilen ikon.
    var icon: String {
        switch self {
        case .home: return "house"
        case .period: return "calendar"
        }
    }

    /// Seçiliyken gösterilen (dolu) ikon.
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .period: return "calendar"
        }
    }
}
