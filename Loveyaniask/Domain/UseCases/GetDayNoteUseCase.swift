//
//  GetDayNoteUseCase.swift
//  Loveyaniask
//

import Foundation

struct GetDayNoteUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(dayKey: String) -> DayNote? {
        repository.note(forDayKey: dayKey)
    }
}
