//
//  GetTimeTogetherUseCase.swift
//  Loveyaniask
//
//  "Şu ana kadar tam olarak ne kadar süredir beraberiz?"
//  Başlangıç tarihinden verilen ana kadar geçen süreyi
//  gün/saat/dakika/saniye olarak verir. Canlı sayaç her saniye çağırır.
//

import Foundation

struct GetTimeTogetherUseCase {
    private let repository: CoupleRepository

    init(repository: CoupleRepository) {
        self.repository = repository
    }

    func execute(asOf now: Date = Date()) -> TimeTogether {
        let couple = repository.fetchCouple()
        guard couple.relationshipStartDate <= now else { return .zero }

        let components = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: couple.relationshipStartDate,
            to: now
        )

        return TimeTogether(
            days: components.day ?? 0,
            hours: components.hour ?? 0,
            minutes: components.minute ?? 0,
            seconds: components.second ?? 0
        )
    }
}
