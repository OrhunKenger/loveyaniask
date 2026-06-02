//
//  SavePeriodSettingsUseCase.swift
//  Loveyaniask
//
//  Regl ayarlarını kaydeder.
//

import Foundation

struct SavePeriodSettingsUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute(_ settings: PeriodSettings) {
        repository.save(settings)
    }
}
