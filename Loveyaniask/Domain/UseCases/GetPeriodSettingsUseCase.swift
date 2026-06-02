//
//  GetPeriodSettingsUseCase.swift
//  Loveyaniask
//
//  Kayıtlı regl ayarlarını getirir.
//

import Foundation

struct GetPeriodSettingsUseCase {
    private let repository: PeriodRepository

    init(repository: PeriodRepository) {
        self.repository = repository
    }

    func execute() -> PeriodSettings {
        repository.fetchSettings()
    }
}
