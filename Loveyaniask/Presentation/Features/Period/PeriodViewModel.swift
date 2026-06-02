//
//  PeriodViewModel.swift
//  Loveyaniask
//
//  Regl takvimi ekranının sunum mantığı: ayarları okur/kaydeder,
//  takvim ızgarasını ve özet tahminleri hazırlar.
//

import Foundation
import Observation

@Observable
final class PeriodViewModel {
    private(set) var settings: PeriodSettings
    var displayedMonth: Date

    private let getSettings: GetPeriodSettingsUseCase
    private let saveSettings: SavePeriodSettingsUseCase

    let weekdaySymbols = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    init(getSettings: GetPeriodSettingsUseCase, saveSettings: SavePeriodSettingsUseCase) {
        self.getSettings = getSettings
        self.saveSettings = saveSettings
        self.settings = getSettings.execute()
        self.displayedMonth = Calendar.current.startOfDay(for: Date())
    }

    private var calendar: Calendar { Calendar.current }
    private var predictor: CyclePredictor { CyclePredictor(settings: settings) }

    // MARK: - Aksiyonlar

    func save(lastPeriodStart: Date, cycleLength: Int, periodLength: Int) {
        let updated = PeriodSettings(
            lastPeriodStart: calendar.startOfDay(for: lastPeriodStart),
            cycleLength: cycleLength,
            periodLength: periodLength
        )
        settings = updated
        saveSettings.execute(updated)
    }

    func goToPreviousMonth() {
        if let date = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = date
        }
    }

    func goToNextMonth() {
        if let date = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = date
        }
    }

    // MARK: - Takvim ızgarası

    /// Gösterilen ay için hücreler. Baştaki nil'ler haftanın ilk gününe hizalar (Pzt başlangıçlı).
    func dayCells() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstOfMonth = interval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30
        let weekday = calendar.component(.weekday, from: firstOfMonth) // 1 = Pazar
        let leadingEmpty = (weekday + 5) % 7                            // Pazartesi başlangıçlı

        var cells: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for offset in 0..<daysInMonth {
            cells.append(calendar.date(byAdding: .day, value: offset, to: firstOfMonth))
        }
        return cells
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    func kind(for date: Date) -> CycleDayKind {
        predictor.kind(for: date)
    }

    func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // MARK: - Özet bilgiler

    var currentCycleDay: Int { predictor.currentCycleDay() }

    var daysUntilNextPeriod: Int { predictor.daysUntilNextPeriod() }

    var nextPeriodDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: predictor.nextPeriodStart())
    }
}
