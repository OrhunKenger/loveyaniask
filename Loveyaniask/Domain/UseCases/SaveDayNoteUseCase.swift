//
//  SaveDayNoteUseCase.swift
//  Loveyaniask
//

import Foundation

struct SaveDayNoteUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(_ note: DayNote) {
        repository.saveNote(note)
    }
}
