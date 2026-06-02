//
//  PeriodLocalDataSource.swift
//  Loveyaniask
//
//  Regl verisinin yerel kaynağı: ayarlar + kayıtlar + notlar (UserDefaults).
//

import Foundation

protocol PeriodLocalDataSource {
    func load() -> PeriodSettings
    func save(_ settings: PeriodSettings)
    func loadLogs() -> [PeriodLog]
    func saveLogs(_ logs: [PeriodLog])
    func loadNotes() -> [DayNote]
    func saveNotes(_ notes: [DayNote])
}

final class UserDefaultsPeriodDataSource: PeriodLocalDataSource {
    private let defaults: UserDefaults
    private let lastStartKey = "period.lastPeriodStart"
    private let cycleLengthKey = "period.cycleLength"
    private let periodLengthKey = "period.periodLength"
    private let reminderEnabledKey = "period.reminderEnabled"
    private let reminderDaysKey = "period.reminderDaysBefore"
    private let logsKey = "period.logs"
    private let notesKey = "period.notes"

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
        settings.reminderEnabled = defaults.bool(forKey: reminderEnabledKey)
        let days = defaults.integer(forKey: reminderDaysKey)
        if days > 0 { settings.reminderDaysBefore = days }
        return settings
    }

    func save(_ settings: PeriodSettings) {
        defaults.set(settings.lastPeriodStart, forKey: lastStartKey)
        defaults.set(settings.cycleLength, forKey: cycleLengthKey)
        defaults.set(settings.periodLength, forKey: periodLengthKey)
        defaults.set(settings.reminderEnabled, forKey: reminderEnabledKey)
        defaults.set(settings.reminderDaysBefore, forKey: reminderDaysKey)
    }

    func loadLogs() -> [PeriodLog] {
        guard let data = defaults.data(forKey: logsKey) else { return [] }
        return (try? JSONDecoder().decode([PeriodLog].self, from: data)) ?? []
    }

    func saveLogs(_ logs: [PeriodLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: logsKey)
        }
    }

    func loadNotes() -> [DayNote] {
        guard let data = defaults.data(forKey: notesKey) else { return [] }
        return (try? JSONDecoder().decode([DayNote].self, from: data)) ?? []
    }

    func saveNotes(_ notes: [DayNote]) {
        if let data = try? JSONEncoder().encode(notes) {
            defaults.set(data, forKey: notesKey)
        }
    }
}
