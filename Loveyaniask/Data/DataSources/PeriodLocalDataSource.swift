//
//  PeriodLocalDataSource.swift
//  Loveyaniask
//
//  Regl ayarlarının yerel (cihazda) kaynağı. UserDefaults ile kalıcı.
//

import Foundation

protocol PeriodLocalDataSource {
    func load() -> PeriodSettings
    func save(_ settings: PeriodSettings)
}

final class UserDefaultsPeriodDataSource: PeriodLocalDataSource {
    private let defaults: UserDefaults
    private let lastStartKey = "period.lastPeriodStart"
    private let cycleLengthKey = "period.cycleLength"
    private let periodLengthKey = "period.periodLength"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> PeriodSettings {
        var settings = PeriodSettings.default
        if let start = defaults.object(forKey: lastStartKey) as? Date {
            settings.lastPeriodStart = start
        }
        let cycle = defaults.integer(forKey: cycleLengthKey)
        if cycle > 0 { settings.cycleLength = cycle }
        let length = defaults.integer(forKey: periodLengthKey)
        if length > 0 { settings.periodLength = length }
        return settings
    }

    func save(_ settings: PeriodSettings) {
        defaults.set(settings.lastPeriodStart, forKey: lastStartKey)
        defaults.set(settings.cycleLength, forKey: cycleLengthKey)
        defaults.set(settings.periodLength, forKey: periodLengthKey)
    }
}
