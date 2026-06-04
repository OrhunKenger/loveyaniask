//
//  AddSpecialDayUseCase.swift
//  Loveyaniask
//
//  Yeni bir özel gün ekler.
//

import Foundation

struct AddSpecialDayUseCase {
    private let repository: SpecialDayRepository

    init(repository: SpecialDayRepository) {
        self.repository = repository
    }

    func execute(title: String, emoji: String, date: Date, repeatsYearly: Bool) {
        let day = SpecialDay(
            id: UUID(),
            title: title,
            date: date,
            emoji: emoji,
            repeatsYearly: repeatsYearly,
            isBuiltIn: false
        )
        repository.add(day)
    }
}
