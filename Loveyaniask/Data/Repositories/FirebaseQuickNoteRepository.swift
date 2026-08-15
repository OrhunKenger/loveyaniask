//
//  FirebaseQuickNoteRepository.swift
//  Loveyaniask
//
//  Hızlı notların Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  JSON ağacı:
//    quickNotes/{uuid} -> { text, authorKey, createdAt }
//  Tarihler saniye (timeIntervalSince1970) olarak sayı tutulur.
//

import Foundation
import FirebaseDatabase

final class FirebaseQuickNoteRepository: QuickNoteRepository {
    private let root = Database.database().reference()
    private var handle: DatabaseHandle?

    private var notesRef: DatabaseReference { root.child("quickNotes") }

    func observeNotes(_ onChange: @escaping ([QuickNote]) -> Void) {
        handle = notesRef.observe(.value) { snapshot in
            var notes: [QuickNote] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let d = child.value as? [String: Any],
                      let text = d["text"] as? String,
                      let authorKey = d["authorKey"] as? String,
                      let created = d["createdAt"] as? TimeInterval,
                      let id = UUID(uuidString: child.key) else { continue }
                notes.append(QuickNote(
                    id: id,
                    text: text,
                    authorKey: authorKey,
                    createdAt: Date(timeIntervalSince1970: created)
                ))
            }
            // En yeni en üstte.
            notes.sort { $0.createdAt > $1.createdAt }
            onChange(notes)
        }
    }

    func addNote(text: String, authorKey: String) {
        let id = UUID()
        notesRef.child(id.uuidString).setValue([
            "text": text,
            "authorKey": authorKey,
            "createdAt": Date().timeIntervalSince1970
        ])
    }

    func deleteNote(id: UUID) {
        notesRef.child(id.uuidString).removeValue()
    }

    func stop() {
        if let handle { notesRef.removeObserver(withHandle: handle) }
        handle = nil
    }

    deinit {
        stop()
    }
}
