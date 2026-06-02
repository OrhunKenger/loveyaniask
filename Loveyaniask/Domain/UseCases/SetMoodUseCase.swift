//
//  SetMoodUseCase.swift
//  Loveyaniask
//
//  Belirli bir gün ve kişi için ruh halini ayarlar (varsa günceller).
//

import Foundation

struct SetMoodUseCase {
    private let repository: MoodRepository

    init(repository: MoodRepository) {
        self.repository = repository
    }

    func execute(date: Date, partner: Partner, mood: Mood) {
        let key = DayKey.make(date)
        var entry = repository.entry(dayKey: key, partner: partner)
            ?? MoodEntry(id: UUID(), dayKey: key, partner: partner, mood: nil, photoFileName: nil)
        entry.mood = mood
        repository.upsert(entry)
    }
}
