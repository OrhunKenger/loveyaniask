//
//  UpdatePlanUseCase.swift
//  Loveyaniask
//
//  Var olan bir planı günceller (aynı id korunur).
//

import Foundation

struct UpdatePlanUseCase {
    private let repository: PlanRepository

    init(repository: PlanRepository) {
        self.repository = repository
    }

    func execute(_ plan: Plan) {
        repository.update(plan)
    }
}
