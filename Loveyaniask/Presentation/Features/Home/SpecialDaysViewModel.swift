//
//  SpecialDaysViewModel.swift
//  Loveyaniask
//
//  Özel günler bölümünün sunum mantığı: listeyi kalan güne göre sıralar,
//  geri sayımları hesaplar, seçilen günü sheet için tutar.
//

import Foundation
import Observation

/// Ekleme/düzenleme sheet hedefi (day = nil ise yeni).
struct SpecialDayFormTarget: Identifiable {
    let id = UUID()
    let day: SpecialDay?
}

@Observable
final class SpecialDaysViewModel {
    private(set) var days: [SpecialDay] = []
    var selectedDay: SpecialDay?
    var formTarget: SpecialDayFormTarget?

    private let getDays: GetSpecialDaysUseCase
    private let observeDaysUseCase: ObserveSpecialDaysUseCase
    private let addDayUseCase: AddSpecialDayUseCase
    private let updateDayUseCase: UpdateSpecialDayUseCase
    private let deleteDayUseCase: DeleteSpecialDayUseCase
    private let calculator = SpecialDayCalculator()
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()

    init(
        getDays: GetSpecialDaysUseCase,
        observeDays: ObserveSpecialDaysUseCase,
        addDay: AddSpecialDayUseCase,
        updateDay: UpdateSpecialDayUseCase,
        deleteDay: DeleteSpecialDayUseCase
    ) {
        self.getDays = getDays
        self.observeDaysUseCase = observeDays
        self.addDayUseCase = addDay
        self.updateDayUseCase = updateDay
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

    func update(_ day: SpecialDay, title: String, emoji: String, date: Date, repeatsYearly: Bool) {
        guard !day.isBuiltIn else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let updated = SpecialDay(
            id: day.id, title: trimmed, date: date, emoji: emoji,
            repeatsYearly: repeatsYearly, isBuiltIn: false
        )
        updateDayUseCase.execute(updated)
    }

    func startNew() { formTarget = SpecialDayFormTarget(day: nil) }
    func startEdit(_ day: SpecialDay) {
        guard !day.isBuiltIn else { return }
        formTarget = SpecialDayFormTarget(day: day)
    }

    func delete(_ day: SpecialDay) {
        guard !day.isBuiltIn else { return }
        deleteDayUseCase.execute(id: day.id)
    }

    func daysRemaining(for day: SpecialDay) -> Int {
        calculator.daysRemaining(to: day)
    }

    func nextDateText(for day: SpecialDay) -> String {
        Self.dateFormatter.string(from: calculator.nextOccurrence(of: day))
    }

    func select(_ day: SpecialDay) {
        selectedDay = day
    }
}
