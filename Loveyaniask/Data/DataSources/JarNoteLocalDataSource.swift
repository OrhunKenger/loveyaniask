//
//  JarNoteLocalDataSource.swift
//  Loveyaniask
//
//  Kavanoz notlarının yerel kaynağı. UserDefaults + JSON.
//

import Foundation

protocol JarNoteLocalDataSource {
    func load() -> [JarNote]
    func save(_ notes: [JarNote])
}

final class UserDefaultsJarNoteDataSource: JarNoteLocalDataSource {
    private let defaults: UserDefaults
    private let key = "jar.notes"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [JarNote] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([JarNote].self, from: data)) ?? []
    }

    func save(_ notes: [JarNote]) {
        if let data = try? JSONEncoder().encode(notes) {
            defaults.set(data, forKey: key)
        }
    }
}
