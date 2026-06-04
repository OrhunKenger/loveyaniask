//
//  DeleteSpecialDayUseCase.swift
//  Loveyaniask
//
//  Kullanıcının eklediği bir özel günü siler.
//

import Foundation

struct DeleteSpecialDayUseCase {
    private let repository: SpecialDayRepository

    init(repository: SpecialDayRepository) {
        self.repository = repository
    }

    func execute(id: UUID) {
        repository.delete(id: id)
    }
}
