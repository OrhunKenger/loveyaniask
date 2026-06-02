//
//  LogPeriodUseCase.swift
//  Loveyaniask
//
//  Gerçek bir regl başlangıcı kaydeder.
//

import Foundation

struct LogPeriodUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(date: Date) {
        let start = Calendar.current.startOfDay(for: date)
        repository.addLog(PeriodLog(id: UUID(), startDate: start))
    }
}
