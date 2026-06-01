//
//  GetDaysTogetherUseCase.swift
//  Loveyaniask
//
//  Tek bir iş kuralı: "kaç gündür beraberiz?" sorusunu yanıtlar.
//  Repository'den çifti alır, bugüne göre geçen gün sayısını hesaplar.
//

import Foundation

struct GetDaysTogetherUseCase {
    private let repository: CoupleRepository

    init(repository: CoupleRepository) {
        self.repository = repository
    }

    func execute(asOf today: Date = Date()) -> Output {
        let couple = repository.fetchCouple()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: couple.relationshipStartDate)
        let now = calendar.startOfDay(for: today)
        let elapsed = calendar.dateComponents([.day], from: start, to: now).day ?? 0
        return Output(days: max(0, elapsed), startDate: couple.relationshipStartDate)
    }

    /// Use case'in döndürdüğü sonuç (Presentation'a taşınacak veri).
    struct Output {
        let days: Int
        let startDate: Date
    }
}
