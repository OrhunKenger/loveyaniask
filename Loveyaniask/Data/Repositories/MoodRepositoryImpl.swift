//
//  MoodRepositoryImpl.swift
//  Loveyaniask
//
//  MoodRepository protokolünün gerçek implementasyonu.
//  Kayıtları bellekte tutar, her değişiklikte data source'a yazar.
//

import Foundation

final class MoodRepositoryImpl: MoodRepository {
    private let localDataSource: MoodLocalDataSource
    private var cache: [MoodEntry]

    init(localDataSource: MoodLocalDataSource) {
        self.localDataSource = localDataSource
        self.cache = localDataSource.load()
    }

    func allEntries() -> [MoodEntry] {
        cache
    }

    func entry(dayKey: String, partner: Partner) -> MoodEntry? {
        cache.first { $0.dayKey == dayKey && $0.partner == partner }
    }

    func upsert(_ entry: MoodEntry) {
        if let index = cache.firstIndex(where: { $0.dayKey == entry.dayKey && $0.partner == entry.partner }) {
            cache[index] = entry
        } else {
            cache.append(entry)
        }
        localDataSource.save(cache)
    }
}
