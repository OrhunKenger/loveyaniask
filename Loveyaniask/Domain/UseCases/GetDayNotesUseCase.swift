//
//  GetDayNotesUseCase.swift
//  Loveyaniask
//
//  Tüm günlük notları getirir.
//

import Foundation

struct GetDayNotesUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute() -> [DayNote] {
        repository.notes()
    }
}
