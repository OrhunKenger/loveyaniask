//
//  FirebaseProfileRepository.swift
//  Loveyaniask
//
//  Profillerin Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  JSON ağacı:
//    profiles/{userKey} -> { bio, photo(base64) }
//

import Foundation
import FirebaseDatabase

final class FirebaseProfileRepository: ProfileRepository {
    private let root = Database.database().reference()
    private var handle: DatabaseHandle?

    private var ref: DatabaseReference { root.child("profiles") }

    func observeProfiles(_ onChange: @escaping ([String: PartnerProfile]) -> Void) {
        handle = ref.observe(.value) { snapshot in
            var result: [String: PartnerProfile] = [:]
            for case let child as DataSnapshot in snapshot.children {
                let d = child.value as? [String: Any] ?? [:]
                result[child.key] = PartnerProfile(
                    userKey: child.key,
                    bio: d["bio"] as? String ?? "",
                    photoBase64: d["photo"] as? String
                )
            }
            onChange(result)
        }
    }

    func save(userKey: String, bio: String, photoBase64: String?) {
        var value: [String: Any] = ["bio": bio]
        // Yalnızca yeni fotoğraf seçildiyse gönder; nil ise mevcut korunur.
        if let photoBase64 { value["photo"] = photoBase64 }
        ref.child(userKey).updateChildValues(value)
    }

    func stop() {
        if let handle { ref.removeObserver(withHandle: handle) }
        handle = nil
    }

    deinit {
        stop()
    }
}
