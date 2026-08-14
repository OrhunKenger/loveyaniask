//
//  PushNotificationSender.swift
//  Loveyaniask
//
//  Partnere anlık (push) bildirim kuyruğa eklemek için Domain sözleşmesi.
//  Gerçek gönderim, saatte bir çalışan bulut routine'i tarafından yapılır —
//  bu sadece "gönderilecekler" kuyruğuna (notifications/pending) yazar.
//

import Foundation

protocol PushNotificationSender {
    /// dedupeKey: aynı türden bildirimlerin art arda spam olmasını önler
    /// (örn. "mood.orhun", "moment.sevval", "rating.place"). Aynı key için
    /// son gönderimden kısa süre geçtiyse yeni istek sessizce atlanır.
    func send(to targetUser: UserProfile, title: String, body: String, dedupeKey: String)
}
