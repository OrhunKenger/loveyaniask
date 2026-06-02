//
//  GetMoodEntriesUseCase.swift
//  Loveyaniask
//
//  Tüm ruh hali kayıtlarını getirir.
//

import Foundation

struct GetMoodEntriesUseCase {
    private let repository: MoodRepository

    init(repository: MoodRepository) {
        self.repository = repository
    }

    func execute() -> [MoodEntry] {
        repository.allEntries()
    }
}
