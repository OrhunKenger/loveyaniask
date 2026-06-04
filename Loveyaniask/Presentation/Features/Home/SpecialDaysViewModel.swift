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
    var showingAdd = false

    private let getDays: GetSpecialDaysUseCase
    private let observeDaysUseCase: ObserveSpecialDaysUseCase
    private let addDayUseCase: AddSpecialDayUseCase
    private let deleteDayUseCase: DeleteSpecialDayUseCase
    private let calculator = SpecialDayCalculator()

    init(
        getDays: GetSpecialDaysUseCase,
        observeDays: ObserveSpecialDaysUseCase,
        addDay: AddSpecialDayUseCase,
        deleteDay: DeleteSpecialDayUseCase
    ) {
        self.getDays = getDays
        self.observeDaysUseCase = observeDays
        self.addDayUseCase = addDay
        self.deleteDayUseCase = deleteDay
        // Firebase'den gerçek zamanlı dinle, kalan güne göre sırala.
        observeDays.execute { [weak self] days in
            guard let self else { return }
            self.days = days.sorted {
                self.calculator.daysRemaining(to: $0) < self.calculator.daysRemaining(to: $1)
            }
        }
    }

    func add(title: String, emoji: String, date: Date, repeatsYearly: Bool) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addDayUseCase.execute(title: trimmed, emoji: emoji, date: date, repeatsYearly: repeatsYearly)
    }

    func delete(_ day: SpecialDay) {
        guard !day.isBuiltIn else { return }
        deleteDayUseCase.execute(id: day.id)
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
