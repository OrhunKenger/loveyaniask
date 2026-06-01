//
//  CoupleRepositoryImpl.swift
//  Loveyaniask
//
//  Domain'deki CoupleRepository protokolünün gerçek implementasyonu.
//  Veriyi data source'tan alır ve Domain entity'sine dönüştürür.
//  Bağımlılık yönü: Data --> Domain.
//

import Foundation

final class CoupleRepositoryImpl: CoupleRepository {
    private let localDataSource: CoupleLocalDataSource

    init(localDataSource: CoupleLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchCouple() -> Couple {
        Couple(relationshipStartDate: localDataSource.loadStartDate())
    }
}
