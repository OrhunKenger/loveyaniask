//
//  MoodLocalDataSource.swift
//  Loveyaniask
//
//  Ruh hali kayıtlarının yerel kaynağı. UserDefaults + JSON ile kalıcı.
//

import Foundation

protocol MoodLocalDataSource {
    func load() -> [MoodEntry]
    func save(_ entries: [MoodEntry])
}

final class UserDefaultsMoodDataSource: MoodLocalDataSource {
    private let defaults: UserDefaults
    private let key = "mood.entries"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [MoodEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([MoodEntry].self, from: data)) ?? []
    }

    func save(_ entries: [MoodEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }
}
