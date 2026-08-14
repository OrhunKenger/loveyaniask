//
//  DeleteMomentUseCase.swift
//  Loveyaniask
//

import Foundation

struct DeleteMomentUseCase {
    private let repository: MomentRepository

    init(repository: MomentRepository) {
        self.repository = repository
    }

    func execute(_ moment: Moment) {
        repository.delete(moment)
    }
}
