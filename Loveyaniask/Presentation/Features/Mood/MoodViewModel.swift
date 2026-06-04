//
//  MoodViewModel.swift
//  Loveyaniask
//
//  Ruh hali ekranının sunum mantığı: kayıtları okur, ayar yapar,
//  takvim ızgarasını hazırlar.
//

import Foundation
import Observation

/// Sheet'i tarihe göre açmak için Identifiable sarmalayıcı.
struct CalendarDay: Identifiable {
    let id: String
    let date: Date
}

@Observable
final class MoodViewModel {
    private(set) var entries: [MoodEntry] = []
    var displayedMonth: Date
    var selectedDay: CalendarDay?

    private let getEntries: GetMoodEntriesUseCase
    private let setMoodUseCase: SetMoodUseCase
    private let setPhotoUseCase: SetMoodPhotoUseCase
    private let getPhotoUseCase: GetMoodPhotoUseCase
    private let currentUser: UserProfile

    let weekdaySymbols = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]

    init(
        getEntries: GetMoodEntriesUseCase,
        setMoodUseCase: SetMoodUseCase,
        setPhotoUseCase: SetMoodPhotoUseCase,
        getPhotoUseCase: GetMoodPhotoUseCase,
        currentUser: UserProfile
    ) {
        self.getEntries = getEntries
        self.setMoodUseCase = setMoodUseCase
        self.setPhotoUseCase = setPhotoUseCase
        self.getPhotoUseCase = getPhotoUseCase
        self.currentUser = currentUser
        self.entries = getEntries.execute()
        self.displayedMonth = Calendar.current.startOfDay(for: Date())
    }

    // MARK: - Kişiye göre etiketler

    /// Giriş yapan "Ben", karşı taraf takma adıyla görünür.
    func title(for partner: Partner) -> String {
        switch partner {
        case .me: return "Ben"
        case .partner: return currentUser.partner.petName
        }
    }

    var meLabel: String { "Ben" }
    var partnerLabel: String { currentUser.partner.petName }

    private var calendar: Calendar { Calendar.current }

    func reload() {
        entries = getEntries.execute()
    }

    // MARK: - Sorgular

    func entry(for date: Date, partner: Partner) -> MoodEntry? {
        let key = DayKey.make(date)
        return entries.first { $0.dayKey == key && $0.partner == partner }
    }

    func mood(for date: Date, partner: Partner) -> Mood? {
        entry(for: date, partner: partner)?.mood
    }

    func photoData(for date: Date, partner: Partner) -> Data? {
        guard let name = entry(for: date, partner: partner)?.photoFileName else { return nil }
        return getPhotoUseCase.execute(fileName: name)
    }

    // MARK: - Aksiyonlar

    func setMood(date: Date, partner: Partner, mood: Mood) {
        setMoodUseCase.execute(date: date, partner: partner, mood: mood)
        reload()
    }

    func setPhoto(date: Date, partner: Partner, imageData: Data) {
        setPhotoUseCase.execute(date: date, partner: partner, imageData: imageData)
        reload()
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

    func dayNumber(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    /// Gelecek bir gün mü? (bugünden sonrası — kayıt girilemez)
    func isFuture(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    /// Sadece bugün düzenlenebilir; geçmiş günler salt-okunur görüntülenir.
    func canEdit(_ date: Date) -> Bool {
        isToday(date)
    }

    func dayTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM EEEE"
        return formatter.string(from: date)
    }
}
