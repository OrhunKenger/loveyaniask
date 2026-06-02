//
//  PeriodRepositoryImpl.swift
//  Loveyaniask
//
//  PeriodRepository protokolünün gerçek implementasyonu.
//  Bağımlılık yönü: Data --> Domain.
//

import Foundation

final class PeriodRepositoryImpl: PeriodRepository {
    private let localDataSource: PeriodLocalDataSource

    init(localDataSource: PeriodLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchSettings() -> PeriodSettings {
        localDataSource.load()
    }

    func save(_ settings: PeriodSettings) {
        localDataSource.save(settings)
    }
}
