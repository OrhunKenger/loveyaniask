//
//  CyclePredictor.swift
//  Loveyaniask
//
//  Saf hesaplama: ayarlara göre bir günün fazı, döngü konumu, tahminler ve
//  durum metni. Döngü, başlangıçtan itibaren her `cycleLength` günde bir
//  tekrarlanır.
//
//  TEK KAYNAK: Bu dosyadaki `bounds()`, döngünün tüm sınırlarını (regl,
//  yumurtlama, doğurgan pencere, PMS) TEK YERDE hesaplar. `phase(for:)` ve
//  `kind(for:)` ikisi de aynı `bounds()`'tan beslenir — `kind` ayrıca
//  `phase`'in kendisinden türetilir. Böylece takvimdeki renklendirme ile
//  durum kartındaki metin ASLA birbirinden sapamaz (eskiden iki ayrı,
//  senkron olmayan formül vardı — bu dosya onu birleştirir).
//
//  Metodoloji (standart klinik yaklaşım):
//  - Yumurtlama günü = döngü uzunluğu - 14 (luteal faz ~14 gün ile en sabit
//    fazdır, bu yüzden geriye doğru bu şekilde hesaplanır). Regl bitiminden
//    önceye düşmesin diye kırpılır.
//  - Doğurgan pencere = yumurtlamadan 5 gün önce - 1 gün sonrası (7 gün;
//    yumurta ~24 saat, sperm ~5 gün canlı kalabilir).
//  - PMS penceresi = regl başlamadan önceki son 5 gün, doğurgan pencereyle
//    çakışmaz.
//

import Foundation

struct CyclePredictor {
    let settings: PeriodSettings
    private let calendar = Calendar.current

    private func position(of date: Date) -> Int {
        let start = calendar.startOfDay(for: settings.lastPeriodStart)
        let day = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
        let cycle = max(settings.cycleLength, 1)
        var pos = diff % cycle
        if pos < 0 { pos += cycle }
        return pos
    }

    /// Döngünün tüm faz sınırları (0 tabanlı pozisyonlar). Tek kaynak.
    private struct Bounds {
        let period: Int
        let ovulationDay: Int
        let fertileStart: Int
        let fertileEnd: Int
        let pmsStart: Int
    }

    private func bounds() -> Bounds {
        let cycle = max(settings.cycleLength, 1)
        let period = min(max(settings.periodLength, 1), cycle)
        // Yumurtlama, regl bitiminden önceye düşmesin.
        let ovulationDay = min(max(period, cycle - 14), cycle - 1)
        let fertileStart = max(period, ovulationDay - 5)
        let fertileEnd = min(cycle - 1, ovulationDay + 1)
        let pmsStart = max(fertileEnd + 1, cycle - 5)
        return Bounds(period: period, ovulationDay: ovulationDay, fertileStart: fertileStart, fertileEnd: fertileEnd, pmsStart: pmsStart)
    }

    /// Günün 6 fazlı döngü fazı — TEK gerçek kaynak.
    func phase(for date: Date) -> CyclePhase {
        let pos = position(of: date)
        let b = bounds()

        if pos < b.period { return .menstrual }
        if pos == b.ovulationDay { return .ovulation }
        if pos >= b.fertileStart && pos <= b.fertileEnd { return .fertile }
        if pos >= b.pmsStart { return .pms }
        if pos < b.fertileStart { return .follicular }
        return .luteal
    }

    /// Takvim/basit renklendirme için — `phase(for:)`'dan türetilir, ayrı bir
    /// hesabı yoktur.
    func kind(for date: Date) -> CycleDayKind {
        switch phase(for: date) {
        case .menstrual: return .period
        case .ovulation: return .ovulation
        case .fertile: return .fertile
        case .follicular, .luteal, .pms: return .none
        }
    }

    /// PMS penceresine kaç gün kaldı? PMS zaten başladıysa 0.
    func daysUntilPMS(from date: Date = Date()) -> Int {
        let pos = position(of: date)
        let start = bounds().pmsStart
        if pos >= start { return 0 }
        return start - pos
    }

    func currentCycleDay(on date: Date = Date()) -> Int {
        position(of: date) + 1
    }

    func nextPeriodStart(after date: Date = Date()) -> Date {
        let start = calendar.startOfDay(for: settings.lastPeriodStart)
        let day = calendar.startOfDay(for: date)
        let cycle = max(settings.cycleLength, 1)
        let diff = calendar.dateComponents([.day], from: start, to: day).day ?? 0
        let nextOffset = ((diff / cycle) + 1) * cycle
        return calendar.date(byAdding: .day, value: nextOffset, to: start) ?? start
    }

    func daysUntilNextPeriod(from date: Date = Date()) -> Int {
        let day = calendar.startOfDay(for: date)
        let next = nextPeriodStart(after: date)
        return calendar.dateComponents([.day], from: day, to: next).day ?? 0
    }

    // MARK: - Durum metni (bugünün durumu kartı için)

    func statusText(on date: Date = Date()) -> String {
        phase(for: date).statusText
    }

    func statusEmoji(on date: Date = Date()) -> String {
        phase(for: date).emoji
    }
}
