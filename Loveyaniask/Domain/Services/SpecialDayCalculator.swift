//
//  SpecialDayCalculator.swift
//  Loveyaniask
//
//  Bir özel günün bir sonraki gerçekleşme tarihini ve kalan günü hesaplar.
//

import Foundation

struct SpecialDayCalculator {
    private let calendar = Calendar.current

    func nextOccurrence(of day: SpecialDay, from today: Date = Date()) -> Date {
        let start = calendar.startOfDay(for: today)

        if !day.repeatsYearly {
            return calendar.startOfDay(for: day.date)
        }

        var components = calendar.dateComponents([.month, .day], from: day.date)
        let year = calendar.component(.year, from: start)

        components.year = year
        if let thisYear = calendar.date(from: components),
           calendar.startOfDay(for: thisYear) >= start {
            return calendar.startOfDay(for: thisYear)
        }

        components.year = year + 1
        return calendar.startOfDay(for: calendar.date(from: components) ?? start)
    }

    func daysRemaining(to day: SpecialDay, from today: Date = Date()) -> Int {
        let start = calendar.startOfDay(for: today)
        let next = nextOccurrence(of: day, from: today)
        return max(0, calendar.dateComponents([.day], from: start, to: next).day ?? 0)
    }
}
