//
//  SpecialDayRepositoryImpl.swift
//  Loveyaniask
//
//  Şimdilik sabit 3 özel gün. İleride düzenlenebilir hâle getirilebilir.
//

import Foundation

final class SpecialDayRepositoryImpl: SpecialDayRepository {
    func all() -> [SpecialDay] {
        [
            make(title: "Yıldönümümüz", emoji: "❤️", month: 5, day: 10),
            make(title: "Şevval'in Doğum Günü", emoji: "🎂", month: 9, day: 28),
            make(title: "Orhun'un Doğum Günü", emoji: "🎂", month: 4, day: 19)
        ]
    }

    private func make(title: String, emoji: String, month: Int, day: Int) -> SpecialDay {
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = day
        let date = Calendar.current.date(from: components) ?? Date()
        return SpecialDay(id: UUID(), title: title, date: date, emoji: emoji, repeatsYearly: true)
    }
}
