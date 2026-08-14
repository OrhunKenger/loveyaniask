//
//  SpecialDayReminderScheduler.swift
//  Loveyaniask
//
//  Özel günler için yerel hatırlatma bildirimi sözleşmesi.
//

import Foundation

protocol SpecialDayReminderScheduler {
    func requestAuthorization()
    /// Tüm özel gün bildirimlerini yeniden kurar (eskileri silip günceller).
    func reschedule(_ days: [SpecialDay])
}
