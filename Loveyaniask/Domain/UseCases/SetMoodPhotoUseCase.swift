//
//  SetMoodPhotoUseCase.swift
//  Loveyaniask
//
//  Belirli bir gün ve kişi için fotoğraf ekler/değiştirir.
//

import Foundation

struct SetMoodPhotoUseCase {
    private let repository: MoodRepository
    private let photoStore: MoodPhotoStore

    init(repository: MoodRepository, photoStore: MoodPhotoStore) {
        self.repository = repository
        self.photoStore = photoStore
    }

    func execute(date: Date, partner: Partner, imageData: Data) {
        let key = DayKey.make(date)
        guard let fileName = photoStore.save(imageData: imageData) else { return }

        var entry = repository.entry(dayKey: key, partner: partner)
            ?? MoodEntry(id: UUID(), dayKey: key, partner: partner, mood: nil, photoFileName: nil)

        if let old = entry.photoFileName {
            photoStore.delete(named: old)
        }
        entry.photoFileName = fileName
        repository.upsert(entry)
    }
}
