//
//  PeriodViewModel.swift
//  Loveyaniask
//
//  Regl takvimi sunum mantığı: ayarlar, gerçek kayıtlar (tahmin düzeltir),
//  günlük notlar, durum özeti, takvim ızgarası ve hatırlatma.
//

import Foundation
import Observation

@Observable
final class PeriodViewModel {
    private(set) var settings: PeriodSettings
    private(set) var logs: [PeriodLog]
    private(set) var dayNotes: [DayNote]
    var displayedMonth: Date
    var selectedDay: CalendarDay?

    private let getSettings: GetPeriodSettingsUseCase
    private let saveSettingsUseCase: SavePeriodSettingsUseCase
    private let logPeriodUseCase: LogPeriodUseCase
    private let getLogsUseCase: GetPeriodLogsUseCase
    private let deleteLogUseCase: DeletePeriodLogUseCase
    private let getNoteUseCase: GetDayNoteUseCase
    private let saveNoteUseCase: SaveDayNoteUseCase
    private let reminderScheduler: PeriodReminderScheduler

    let weekdaySymbols = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    init(
        getSettings: GetPeriodSettingsUseCase,
        saveSettings: SavePeriodSettingsUseCase,
        logPeriod: LogPeriodUseCase,
        getLogs: GetPeriodLogsUseCase,
        deleteLog: DeletePeriodLogUseCase,
        getNote: GetDayNoteUseCase,
        saveNote: SaveDayNoteUseCase,
        reminderScheduler: PeriodReminderScheduler
    ) {
        self.getSettings = getSettings
        self.saveSettingsUseCase = saveSettings
        self.logPeriodUseCase = logPeriod
        self.getLogsUseCase = getLogs
        self.deleteLogUseCase = deleteLog
        self.getNoteUseCase = getNote
        self.saveNoteUseCase = saveNote
        self.reminderScheduler = reminderScheduler
        self.settings = getSettings.execute()
        self.logs = getLogs.execute()
        self.dayNotes = []
        self.displayedMonth = Calendar.current.startOfDay(for: Date())
    }

    private var calendar: Calendar { Calendar.current }

    /// Gerçek kayıtlar varsa onlara göre düzeltilmiş ayarlar.
    private var effectiveSettings: PeriodSettings {
        var result = settings
        if let latest = logs.map({ $0.startDate }).max() {
            result.lastPeriodStart = latest
        }
        if let avg = averageCycleLength() {
            result.cycleLength = avg
        }
        return result
    }

    private func averageCycleLength() -> Int? {
        let starts = logs.map { calendar.startOfDay(for: $0.startDate) }.sorted()
        guard starts.count >= 2 else { return nil }
        var gaps: [Int] = []
        for index in 1..<starts.count {
            if let gap = calendar.dateComponents([.day], from: starts[index - 1], to: starts[index]).day {
                gaps.append(gap)
            }
        }
        guard !gaps.isEmpty else { return nil }
        let average = gaps.reduce(0, +) / gaps.count
        return min(max(average, 21), 40)
    }

    private var predictor: CyclePredictor { CyclePredictor(settings: effectiveSettings) }

    // MARK: - Durum özeti

    var statusText: String { predictor.statusText() }
    var statusEmoji: String { predictor.statusEmoji() }
    var currentCycleDay: Int { predictor.currentCycleDay() }
    var daysUntilNextPeriod: Int { predictor.daysUntilNextPeriod() }

    var cycleProgress: Double {
        let cycle = max(effectiveSettings.cycleLength, 1)
        return min(1, Double(currentCycleDay) / Double(cycle))
    }

    var nextPeriodDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: predictor.nextPeriodStart())
    }

    // MARK: - Aksiyonlar

    func save(lastPeriodStart: Date, cycleLength: Int, periodLength: Int, reminderEnabled: Bool, reminderDaysBefore: Int) {
        var updated = settings
        updated.lastPeriodStart = calendar.startOfDay(for: lastPeriodStart)
        updated.cycleLength = cycleLength
        updated.periodLength = periodLength
        updated.reminderEnabled = reminderEnabled
        updated.reminderDaysBefore = reminderDaysBefore
        settings = updated
        saveSettingsUseCase.execute(updated)
        if reminderEnabled { reminderScheduler.requestAuthorization() }
        rescheduleReminder()
    }

    func logPeriodToday() {
        logPeriodUseCase.execute(date: Date())
        logs = getLogsUseCase.execute()
        rescheduleReminder()
    }

    func markAsPeriodStart(_ date: Date) {
        logPeriodUseCase.execute(date: date)
        logs = getLogsUseCase.execute()
        rescheduleReminder()
    }

    func deleteLog(_ log: PeriodLog) {
        deleteLogUseCase.execute(id: log.id)
        logs = getLogsUseCase.execute()
        rescheduleReminder()
    }

    func note(for date: Date) -> DayNote? {
        getNoteUseCase.execute(dayKey: DayKey.make(date))
    }

    func hasNote(on date: Date) -> Bool {
        note(for: date)?.isEmpty == false
    }

    func saveNote(for date: Date, symptoms: [Symptom], text: String) {
        let note = DayNote(dayKey: DayKey.make(date), symptoms: symptoms, note: text)
        saveNoteUseCase.execute(note)
    }

    private func rescheduleReminder() {
        guard settings.reminderEnabled else {
            reminderScheduler.cancelAll()
            return
        }
        let next = predictor.nextPeriodStart()
        let remindDate = calendar.date(byAdding: .day, value: -settings.reminderDaysBefore, to: next) ?? next
        reminderScheduler.schedule(
            title: "Regl yaklaşıyor 💗",
            body: "Tahmini regl tarihi \(nextPeriodDateText). Hazırlıklı ol.",
            on: remindDate
        )
    }

    func select(_ date: Date) {
        selectedDay = CalendarDay(id: DayKey.make(date), date: date)
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

    func dayCells() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstOfMonth = interval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (weekday + 5) % 7

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

    func phaseText(for date: Date) -> String {
        switch predictor.kind(for: date) {
        case .period: return "Regl günü 🩸"
        case .ovulation: return "Yumurtlama günü 🥚"
        case .fertile: return "Doğurgan dönem 🌱"
        case .none: return "Normal gün"
        }
    }

    func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func dayTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM EEEE"
        return formatter.string(from: date)
    }

    func logDateText(_ log: PeriodLog) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: log.startDate)
    }
}
