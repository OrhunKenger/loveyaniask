//
//  LocalPeriodReminderScheduler.swift
//  Loveyaniask
//
//  PeriodReminderScheduler'ın yerel bildirim (UNUserNotificationCenter) implementasyonu.
//  Tahmini regl başlangıcından 10, 5 ve 1 gün önce olmak üzere 3 aşamalı hatırlatır.
//

import Foundation
import UserNotifications

final class LocalPeriodReminderScheduler: PeriodReminderScheduler {
    private static let stages: [(daysBefore: Int, prefix: String)] = [
        (10, "10 gün kaldı"),
        (5, "5 gün kaldı"),
        (1, "Yarın başlıyor"),
    ]
    private let identifiers = Self.stages.map { "period.reminder.\($0.daysBefore)" }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func scheduleUpcoming(periodStart: Date, dateText: String) {
        cancelAll()
        let calendar = Calendar.current
        let now = Date()

        for stage in Self.stages {
            guard let fireDate = calendar.date(byAdding: .day, value: -stage.daysBefore, to: periodStart),
                  fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Regl yaklaşıyor 💗"
            content.body = "\(stage.prefix) — tahmini tarih \(dateText). Hazırlıklı ol."
            content.sound = .default

            var components = calendar.dateComponents([.year, .month, .day], from: fireDate)
            components.hour = 10
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "period.reminder.\(stage.daysBefore)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
