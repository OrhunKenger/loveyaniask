//
//  SpecialDaysViewModel.swift
//  Loveyaniask
//
//  Özel günler bölümünün sunum mantığı: listeyi kalan güne göre sıralar,
//  geri sayımları hesaplar, seçilen günü sheet için tutar.
//

import Foundation
import Observation

@Observable
final class SpecialDaysViewModel {
    private(set) var days: [SpecialDay] = []
    var selectedDay: SpecialDay?

    private let getDays: GetSpecialDaysUseCase
    private let calculator = SpecialDayCalculator()

    init(getDays: GetSpecialDaysUseCase) {
        self.getDays = getDays
        self.days = getDays.execute().sorted {
            calculator.daysRemaining(to: $0) < calculator.daysRemaining(to: $1)
        }
    }

    func daysRemaining(for day: SpecialDay) -> Int {
        calculator.daysRemaining(to: day)
    }

    func nextDateText(for day: SpecialDay) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: calculator.nextOccurrence(of: day))
    }

    func select(_ day: SpecialDay) {
        selectedDay = day
    }
}
