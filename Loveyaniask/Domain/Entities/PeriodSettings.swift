//
//  PeriodSettings.swift
//  Loveyaniask
//
//  Regl takvimi ayarları: son regl başlangıcı, döngü uzunluğu, regl süresi.
//  Sevgilinin düzenleyebileceği değerler.
//

import Foundation

struct PeriodSettings {
    var lastPeriodStart: Date
    var cycleLength: Int   // ortalama döngü (gün)
    var periodLength: Int  // regl süresi (gün)

    static var `default`: PeriodSettings {
        PeriodSettings(
            lastPeriodStart: Calendar.current.startOfDay(for: Date()),
            cycleLength: 28,
            periodLength: 5
        )
    }
}
