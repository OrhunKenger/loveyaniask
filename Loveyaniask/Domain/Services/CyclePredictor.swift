//
//  CyclePredictor.swift
//  Loveyaniask
//
//  Saf hesaplama: ayarlara göre bir günün türü, döngü konumu, tahminler ve durum metni.
//  Döngü, başlangıçtan itibaren her `cycleLength` günde bir tekrarlanır.
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

    func kind(for date: Date) -> CycleDayKind {
        let cycle = max(settings.cycleLength, 1)
        let pos = position(of: date)

        if pos < settings.periodLength {
            return .period
        }

        let ovulationDay = cycle - 14
        if pos == ovulationDay {
            return .ovulation
        }
        if pos >= ovulationDay - 2 && pos <= ovulationDay + 1 {
            return .fertile
        }
        return .none
    }

    /// Faz sınırları (0 tabanlı pozisyonlar), döngü uzunluğuna göre.
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
        let ovulationDay = max(period, cycle - 14)
        let fertileStart = ovulationDay - 4
        let fertileEnd = ovulationDay + 1
        let pmsStart = max(fertileEnd + 1, cycle - 4)
        return Bounds(period: period, ovulationDay: ovulationDay, fertileStart: fertileStart, fertileEnd: fertileEnd, pmsStart: pmsStart)
    }

    /// Günün 6 fazlı döngü fazı. Sınırlar döngü uzunluğuna göre hesaplanır.
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
