//
//  PlanReminderScheduler.swift
//  Loveyaniask
//
//  Planlar için yerel hatırlatma bildirimi sözleşmesi.
//

import Foundation

protocol PlanReminderScheduler {
    func requestAuthorization()
    /// Tüm plan bildirimlerini yeniden kurar (eskileri silip günceller).
    func reschedule(_ plans: [Plan])
}
