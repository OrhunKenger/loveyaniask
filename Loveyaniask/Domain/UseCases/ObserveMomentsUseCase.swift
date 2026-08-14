//
//  ObserveMomentsUseCase.swift
//  Loveyaniask
//

import Foundation

struct ObserveMomentsUseCase {
    private let repository: MomentRepository

    init(repository: MomentRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping ([Moment]) -> Void) {
        repository.observe(onChange)
    }
}
