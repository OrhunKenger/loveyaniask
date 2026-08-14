//
//  FirebasePushNotificationSender.swift
//  Loveyaniask
//
//  notifications/pending/{autoId} -> { targetUserKey, title, body, createdAt }
//  Saatte bir çalışan bulut routine'i bu kuyruğu okuyup FCM ile gerçek push'u
//  gönderir, sonra kuyruktan siler.
//
//  notifications/lastSent/{dedupeKey} -> son gönderim zamanı (epoch saniye).
//  Aynı dedupeKey için kısa aralıkta art arda istek gelirse (örn. peş peşe
//  puan değiştirme), sonrakiler sessizce atlanır — partner spam bildirim almasın.
//

import Foundation
import FirebaseDatabase

final class FirebasePushNotificationSender: PushNotificationSender {
    private let pendingRef = Database.database().reference().child("notifications").child("pending")
    private let lastSentRef = Database.database().reference().child("notifications").child("lastSent")
    /// Aynı dedupeKey için minimum bekleme süresi.
    private let minInterval: TimeInterval = 600

    func send(to targetUser: UserProfile, title: String, body: String, dedupeKey: String) {
        let key = Self.sanitize(dedupeKey)
        lastSentRef.child(key).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            let now = Date().timeIntervalSince1970
            if let last = snapshot.value as? Double, now - last < self.minInterval {
                return
            }
            self.lastSentRef.child(key).setValue(now)
            self.pendingRef.childByAutoId().setValue([
                "targetUserKey": targetUser.rawValue,
                "title": title,
                "body": body,
                "createdAt": ServerValue.timestamp()
            ]) { error, _ in
                if let error {
                    print("PushNotificationSender: kuyruğa yazılamadı — \(error.localizedDescription)")
                }
            }
        }
    }

    private static func sanitize(_ key: String) -> String {
        let invalid = CharacterSet(charactersIn: ".#$[]/")
        return key.components(separatedBy: invalid).joined(separator: "_")
    }
}
