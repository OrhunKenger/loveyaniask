//
//  DeletePlanUseCase.swift
//  Loveyaniask
//
//  Bir planı siler.
//

import Foundation

struct DeletePlanUseCase {
    private let repository: PlanRepository

    init(repository: PlanRepository) {
        self.repository = repository
    }

    func execute(id: UUID) {
        repository.delete(id: id)
    }
}
