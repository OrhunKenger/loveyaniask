//
//  ObservePlansUseCase.swift
//  Loveyaniask
//
//  Planları gerçek zamanlı dinler.
//

import Foundation

struct ObservePlansUseCase {
    private let repository: PlanRepository

    init(repository: PlanRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping ([Plan]) -> Void) {
        repository.observe(onChange)
    }
}
