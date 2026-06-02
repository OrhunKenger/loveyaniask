//
//  PlaceLocalDataSource.swift
//  Loveyaniask
//
//  Mekanların yerel kaynağı. UserDefaults + JSON ile kalıcı.
//

import Foundation

protocol PlaceLocalDataSource {
    func load() -> [Place]
    func save(_ places: [Place])
}

final class UserDefaultsPlaceDataSource: PlaceLocalDataSource {
    private let defaults: UserDefaults
    private let key = "places.entries"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Place] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Place].self, from: data)) ?? []
    }

    func save(_ places: [Place]) {
        if let data = try? JSONEncoder().encode(places) {
            defaults.set(data, forKey: key)
        }
    }
}
