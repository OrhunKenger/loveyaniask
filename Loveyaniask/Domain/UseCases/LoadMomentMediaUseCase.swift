//
//  LoadMomentMediaUseCase.swift
//  Loveyaniask
//

import Foundation

struct LoadMomentMediaUseCase {
    private let repository: MomentRepository

    init(repository: MomentRepository) {
        self.repository = repository
    }

    func execute(_ moment: Moment, completion: @escaping (URL?) -> Void) {
        repository.localFileURL(for: moment, completion: completion)
    }
}
