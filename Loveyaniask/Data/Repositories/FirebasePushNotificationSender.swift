//
//  FirebasePushNotificationSender.swift
//  Loveyaniask
//
//  notifications/pending/{autoId} -> { targetUserKey, title, body, createdAt }
//  Saatte bir çalışan bulut routine'i bu kuyruğu okuyup FCM ile gerçek push'u
//  gönderir, sonra kuyruktan siler.
//

import Foundation
import FirebaseDatabase

final class FirebasePushNotificationSender: PushNotificationSender {
    private let ref = Database.database().reference().child("notifications").child("pending")

    func send(to targetUser: UserProfile, title: String, body: String) {
        ref.childByAutoId().setValue([
            "targetUserKey": targetUser.rawValue,
            "title": title,
            "body": body,
            "createdAt": ServerValue.timestamp()
        ])
    }
}
