//
//  UpdateSpecialDayUseCase.swift
//  Loveyaniask
//
//  Var olan (kullanıcının eklediği) bir özel günü günceller.
//

import Foundation

struct UpdateSpecialDayUseCase {
    private let repository: SpecialDayRepository

    init(repository: SpecialDayRepository) {
        self.repository = repository
    }

    func execute(_ day: SpecialDay) {
        repository.update(day)
    }
}
