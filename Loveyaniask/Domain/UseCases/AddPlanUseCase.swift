//
//  AddPlanUseCase.swift
//  Loveyaniask
//
//  Yeni bir yaklaşan plan ekler.
//

import Foundation

struct AddPlanUseCase {
    private let repository: PlanRepository

    init(repository: PlanRepository) {
        self.repository = repository
    }

    func execute(title: String, date: Date, note: String, remindEnabled: Bool, authorKey: String) {
        let plan = Plan(
            id: UUID(),
            title: title,
            date: date,
            note: note,
            remindEnabled: remindEnabled,
            authorKey: authorKey
        )
        repository.add(plan)
    }
}
