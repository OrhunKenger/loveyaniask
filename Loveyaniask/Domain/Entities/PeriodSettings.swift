//
//  PeriodSettings.swift
//  Loveyaniask
//
//  Regl takvimi ayarları: döngü/regl uzunluğu, başlangıç ve hatırlatma.
//

import Foundation

struct PeriodSettings {
    var lastPeriodStart: Date
    var cycleLength: Int   // ortalama döngü (gün)
    var periodLength: Int  // regl süresi (gün)
    var reminderEnabled: Bool
    var reminderDaysBefore: Int

    static var `default`: PeriodSettings {
        PeriodSettings(
            lastPeriodStart: Calendar.current.startOfDay(for: Date()),
            cycleLength: 28,
            periodLength: 5,
            reminderEnabled: false,
            reminderDaysBefore: 2
        )
    }
}
