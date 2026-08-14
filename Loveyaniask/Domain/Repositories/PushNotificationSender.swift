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
    func send(to targetUser: UserProfile, title: String, body: String)
}
