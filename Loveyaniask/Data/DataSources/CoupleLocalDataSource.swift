//
//  CoupleLocalDataSource.swift
//  Loveyaniask
//
//  Çift verisinin yerel (cihazda) kaynağı. Şimdilik UserDefaults.
//  İleride backend eklenince bunun yanına bir RemoteDataSource gelebilir.
//

import Foundation

protocol CoupleLocalDataSource {
    func loadStartDate() -> Date
}

final class UserDefaultsCoupleDataSource: CoupleLocalDataSource {
    private let defaults: UserDefaults
    private let startDateKey = "couple.relationshipStartDate"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadStartDate() -> Date {
        if let stored = defaults.object(forKey: startDateKey) as? Date {
            return stored
        }
        return Self.defaultStartDate
    }

    /// Varsayılan beraberlik tarihi: 10 Mayıs 2026.
    static var defaultStartDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 10
        return Calendar.current.date(from: components) ?? Date()
    }
}
