//
//  FirebaseMoodRepository.swift
//  Loveyaniask
//
//  Ruh hallerinin Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  mood/{dayKey}/{userKey} -> { mood?, photoFileName? }
//  userKey = gerçek kişi (orhun/sevval). .me/.partner göreceliliği currentUser'a göre çevrilir.
//  NOT: fotoğraflar cihazda yerel (FileMoodPhotoStore); sadece dosya adı saklanır.
//

import Foundation
import FirebaseDatabase

final class FirebaseMoodRepository: MoodRepository {
    private let ref = Database.database().reference().child("mood")
    private let currentUser: UserProfile
    private var cache: [MoodEntry] = []
    private var onChange: (([MoodEntry]) -> Void)?
    private var handle: DatabaseHandle?

    init(currentUser: UserProfile) {
        self.currentUser = currentUser
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var entries: [MoodEntry] = []
            for case let dayChild as DataSnapshot in snapshot.children {
                let dayKey = dayChild.key
                for case let userChild as DataSnapshot in dayChild.children {
                    let userKey = userChild.key
                    guard let d = userChild.value as? [String: Any] else { continue }
                    let partner: Partner = (userKey == self.currentUser.rawValue) ? .me : .partner
                    let mood = (d["mood"] as? String).flatMap { Mood(rawValue: $0) }
                    let photo = d["photoFileName"] as? String
                    entries.append(MoodEntry(
                        id: UUID(), dayKey: dayKey, partner: partner,
                        mood: mood, photoFileName: photo
                    ))
                }
            }
            self.cache = entries
            self.onChange?(entries)
        }
    }

    func observe(_ onChange: @escaping ([MoodEntry]) -> Void) {
        self.onChange = onChange
        onChange(cache)
    }

    func allEntries() -> [MoodEntry] { cache }

    func entry(dayKey: String, partner: Partner) -> MoodEntry? {
        cache.first { $0.dayKey == dayKey && $0.partner == partner }
    }

    func upsert(_ entry: MoodEntry) {
        let ownerKey = (entry.partner == .me) ? currentUser.rawValue : currentUser.partner.rawValue

        // Optimistik önbellek güncelle.
        if let i = cache.firstIndex(where: { $0.dayKey == entry.dayKey && $0.partner == entry.partner }) {
            cache[i] = entry
        } else {
            cache.append(entry)
        }
        onChange?(cache)

        var data: [String: Any] = [:]
        if let mood = entry.mood { data["mood"] = mood.rawValue }
        if let photo = entry.photoFileName { data["photoFileName"] = photo }
        ref.child(entry.dayKey).child(ownerKey).setValue(data)
    }
}
