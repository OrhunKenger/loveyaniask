//
//  GetSpecialDaysUseCase.swift
//  Loveyaniask
//

import Foundation

struct GetSpecialDaysUseCase {
    private let repository: SpecialDayRepository

    init(repository: SpecialDayRepository) {
        self.repository = repository
    }

    func execute() -> [SpecialDay] {
        repository.all()
    }
}
