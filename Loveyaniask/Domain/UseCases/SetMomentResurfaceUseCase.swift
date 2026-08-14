//
//  SetMomentResurfaceUseCase.swift
//  Loveyaniask
//

import Foundation

struct SetMomentResurfaceUseCase {
    private let repository: MomentRepository

    init(repository: MomentRepository) {
        self.repository = repository
    }

    func execute(_ moment: Moment, date: Date?) {
        repository.setResurface(moment, date: date)
    }
}
