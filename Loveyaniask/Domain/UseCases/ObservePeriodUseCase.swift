//
//  ObservePeriodUseCase.swift
//  Loveyaniask
//
//  Regl verisini gerçek zamanlı dinler.
//

import Foundation

struct ObservePeriodUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping () -> Void) {
        repository.observe(onChange)
    }
}
