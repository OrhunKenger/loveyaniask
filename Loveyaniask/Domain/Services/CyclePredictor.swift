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
        switch kind(for: date) {
        case .period:
            return "Regl dönemindesin"
        case .ovulation:
            return "Yumurtlama günü"
        case .fertile:
            return "Doğurgan dönem"
        case .none:
            return "Regle \(daysUntilNextPeriod(from: date)) gün var"
        }
    }

    func statusEmoji(on date: Date = Date()) -> String {
        switch kind(for: date) {
        case .period: return "🩸"
        case .ovulation: return "🥚"
        case .fertile: return "🌱"
        case .none: return "🌸"
        }
    }
}
