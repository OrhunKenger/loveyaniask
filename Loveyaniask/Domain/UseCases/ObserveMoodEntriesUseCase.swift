//
//  ObserveMoodEntriesUseCase.swift
//  Loveyaniask
//
//  Ruh hali kayıtlarını gerçek zamanlı dinler.
//

import Foundation

struct ObserveMoodEntriesUseCase {
    private let repository: MoodRepository

    init(repository: MoodRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping ([MoodEntry]) -> Void) {
        repository.observe(onChange)
    }
}
