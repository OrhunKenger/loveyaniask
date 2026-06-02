//
//  GetPeriodLogsUseCase.swift
//  Loveyaniask
//
//  Kayıtlı regl başlangıçlarını (yeniden eskiye) getirir.
//

import Foundation

struct GetPeriodLogsUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute() -> [PeriodLog] {
        repository.logs().sorted { $0.startDate > $1.startDate }
    }
}
