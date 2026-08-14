//
//  OnThisDayReminderScheduler.swift
//  Loveyaniask
//

import Foundation

protocol OnThisDayReminderScheduler {
    func requestAuthorization()
    /// Akış anları arasında bugünün tarihine (ay/gün) denk gelen geçmiş yıl
    /// kaydı varsa, günde bir kez akşam bir hatırlatma kurar.
    func checkAndSchedule(moments: [Moment])
}
