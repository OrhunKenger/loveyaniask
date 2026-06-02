//
//  DeletePeriodLogUseCase.swift
//  Loveyaniask
//

import Foundation

struct DeletePeriodLogUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(id: UUID) {
        repository.deleteLog(id: id)
    }
}
