//
//  ObserveSpecialDaysUseCase.swift
//  Loveyaniask
//
//  Özel günleri gerçek zamanlı dinler.
//

import Foundation

struct ObserveSpecialDaysUseCase {
    private let repository: SpecialDayRepository

    init(repository: SpecialDayRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping ([SpecialDay]) -> Void) {
        repository.observe(onChange)
    }
}
