//
//  LocalSpecialDayReminderScheduler.swift
//  Loveyaniask
//
//  Özel günler için yerel bildirim (UNUserNotificationCenter).
//  Her özel gün için: 30, 15 ve 5 gün önce hatırlatır. Yıllık tekrarlayan
//  günlerde bir sonraki gerçekleşme (SpecialDayCalculator) baz alınır.
//

import Foundation
import UserNotifications

final class LocalSpecialDayReminderScheduler: SpecialDayReminderScheduler {
    private let calculator = SpecialDayCalculator()
    private static let stages: [(daysBefore: Int, prefix: String)] = [
        (30, "30 gün kaldı"),
        (15, "15 gün kaldı"),
        (5, "5 gün kaldı"),
    ]

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func reschedule(_ days: [SpecialDay]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.map { $0.identifier }.filter { $0.hasPrefix("specialday.") }
            center.removePendingNotificationRequests(withIdentifiers: ids)

            let now = Date()
            let calendar = Calendar.current

            for day in days {
                let next = self.calculator.nextOccurrence(of: day, from: now)
                for stage in Self.stages {
                    guard let fireDate = calendar.date(byAdding: .day, value: -stage.daysBefore, to: next),
                          fireDate > now else { continue }

                    let content = UNMutableNotificationContent()
                    content.title = "\(day.emoji) \(day.title) yaklaşıyor"
                    content.body = "\(stage.prefix)"
                    content.sound = .default

                    var components = calendar.dateComponents([.year, .month, .day], from: fireDate)
                    components.hour = 10
                    components.minute = 0

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: "specialday.\(day.id.uuidString).\(stage.daysBefore)",
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                }
            }
        }
    }
}
