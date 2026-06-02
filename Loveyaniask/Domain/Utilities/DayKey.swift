//
//  DayKey.swift
//  Loveyaniask
//
//  Bir tarihi "gün" bazında benzersiz bir anahtara çevirir (yyyy-MM-dd).
//  Saat farkından etkilenmeden günleri eşleştirmek için kullanılır.
//

import Foundation

enum DayKey {
    static func make(_ date: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
