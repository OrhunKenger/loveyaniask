//
//  PeriodReminderScheduler.swift
//  Loveyaniask
//
//  Regl hatırlatma bildirimleri için Domain sözleşmesi.
//

import Foundation

protocol PeriodReminderScheduler {
    func requestAuthorization()
    /// Tahmini regl başlangıcına göre 10/5/1 gün önce hatırlatmaları kurar
    /// (geçmişte kalanlar atlanır).
    func scheduleUpcoming(periodStart: Date, dateText: String)
    func cancelAll()
}
