//
//  LocalOnThisDayReminderScheduler.swift
//  Loveyaniask
//
//  "Bugün geçmişte" hatırlatıcısı: Akış'ta bugünün ay/gününe denk gelen
//  önceki yıllardan bir an varsa, akşam (19:00) bir kez yerel bildirim kurar.
//  Push/sunucu gerekmez — veri zaten cihazda/Firebase'de.
//

import Foundation
import UserNotifications

final class LocalOnThisDayReminderScheduler: OnThisDayReminderScheduler {
    private let identifier = "onthisday.reminder"
    private let lastShownKey = "onThisDay.lastShownDayKey"
    private let calendar = Calendar.current

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func checkAndSchedule(moments: [Moment]) {
        let today = Date()
        let todayKey = DayKey.make(today)

        // Günde bir kez kontrol yeter.
        guard UserDefaults.standard.string(forKey: lastShownKey) != todayKey else { return }

        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        let currentYear = calendar.component(.year, from: today)

        let pastMoments = moments.filter { moment in
            let c = calendar.dateComponents([.year, .month, .day], from: moment.createdAt)
            return c.month == todayComponents.month && c.day == todayComponents.day && (c.year ?? currentYear) < currentYear
        }
        guard let match = pastMoments.first else { return }

        let yearsAgo = currentYear - (calendar.component(.year, from: match.createdAt))
        UserDefaults.standard.set(todayKey, forKey: lastShownKey)

        let content = UNMutableNotificationContent()
        content.title = "Bugün geçmişte 💭"
        content.body = yearsAgo == 1
            ? "1 yıl önce bugün Akış'ta bir anınız vardı — bakmak ister misin?"
            : "\(yearsAgo) yıl önce bugün Akış'ta bir anınız vardı — bakmak ister misin?"
        content.sound = .default

        var fireComponents = calendar.dateComponents([.year, .month, .day], from: today)
        fireComponents.hour = 19
        fireComponents.minute = 0

        let fireDate = calendar.date(from: fireComponents) ?? today
        let trigger: UNNotificationTrigger
        if fireDate > today {
            trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
        } else {
            // Saat 19:00 geçtiyse hemen (30 sn sonra) göster.
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        }

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
