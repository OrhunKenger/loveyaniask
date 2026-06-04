//
//  LocalPlanReminderScheduler.swift
//  Loveyaniask
//
//  Planlar için yerel bildirim (UNUserNotificationCenter).
//  Her plan için: 1 gün önce + tam zamanında hatırlatır.
//

import Foundation
import UserNotifications

final class LocalPlanReminderScheduler: PlanReminderScheduler {
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func reschedule(_ plans: [Plan]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            // Önce tüm eski plan bildirimlerini temizle.
            let planIds = requests.map { $0.identifier }.filter { $0.hasPrefix("plan.") }
            center.removePendingNotificationRequests(withIdentifiers: planIds)

            let now = Date()
            let calendar = Calendar.current

            for plan in plans where plan.remindEnabled {
                // Tam zamanında
                if plan.date > now {
                    self.add(center,
                             id: "plan.\(plan.id.uuidString).at",
                             title: "📌 \(plan.title)",
                             body: "Plan zamanı geldi: \(plan.title)",
                             date: plan.date)
                }
                // 1 gün önce (aynı saatte)
                if let dayBefore = calendar.date(byAdding: .day, value: -1, to: plan.date),
                   dayBefore > now {
                    self.add(center,
                             id: "plan.\(plan.id.uuidString).before",
                             title: "⏰ Yaklaşan plan",
                             body: "Yarın: \(plan.title)",
                             date: dayBefore)
                }
            }
        }
    }

    private func add(_ center: UNUserNotificationCenter, id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
