//
//  PeriodReminderScheduler.swift
//  Loveyaniask
//
//  Regl hatırlatma bildirimleri için Domain sözleşmesi.
//

import Foundation

protocol PeriodReminderScheduler {
    func requestAuthorization()
    func schedule(title: String, body: String, on date: Date)
    func cancelAll()
}
