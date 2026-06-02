//
//  LocalPeriodReminderScheduler.swift
//  Loveyaniask
//
//  PeriodReminderScheduler'ın yerel bildirim (UNUserNotificationCenter) implementasyonu.
//

import Foundation
import UserNotifications

final class LocalPeriodReminderScheduler: PeriodReminderScheduler {
    private let identifier = "period.reminder"

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func schedule(title: String, body: String, on date: Date) {
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
