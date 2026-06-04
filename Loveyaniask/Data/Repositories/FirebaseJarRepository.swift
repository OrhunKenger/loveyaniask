//
//  FirebaseJarRepository.swift
//  Loveyaniask
//
//  Kavanozun Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  JSON ağacı:
//    jar/capsule        -> { cycleStart, approvals: {orhun, sevval}, openedAt }
//    jar/notes/{uuid}   -> { text, authorKey, createdAt }
//  Tarihler saniye (timeIntervalSince1970) olarak sayı tutulur.
//

import Foundation
import FirebaseDatabase

final class FirebaseJarRepository: JarRepository {
    private let root = Database.database().reference()
    private var capsuleHandle: DatabaseHandle?
    private var notesHandle: DatabaseHandle?

    private var capsuleRef: DatabaseReference { root.child("jar").child("capsule") }
    private var notesRef: DatabaseReference { root.child("jar").child("notes") }

    // MARK: - Observe

    func observeCapsule(_ onChange: @escaping (JarCapsule) -> Void) {
        capsuleHandle = capsuleRef.observe(.value) { [weak self] snapshot in
            guard let self else { return }

            // İlk açılış: düğüm yoksa varsayılan döngüyü oluştur.
            guard let dict = snapshot.value as? [String: Any] else {
                self.capsuleRef.setValue([
                    "cycleStart": Date().timeIntervalSince1970,
                    "approvals": [String: Bool](),
                    "openedAt": NSNull()
                ])
                return
            }

            let cycleStart = (dict["cycleStart"] as? TimeInterval)
                .map { Date(timeIntervalSince1970: $0) } ?? Date()
            let approvals = (dict["approvals"] as? [String: Bool]) ?? [:]
            let openedAt = (dict["openedAt"] as? TimeInterval)
                .map { Date(timeIntervalSince1970: $0) }

            onChange(JarCapsule(cycleStart: cycleStart, approvals: approvals, openedAt: openedAt))
        }
    }

    func observeNotes(_ onChange: @escaping ([JarNote]) -> Void) {
        notesHandle = notesRef.observe(.value) { snapshot in
            var notes: [JarNote] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let d = child.value as? [String: Any],
                      let text = d["text"] as? String,
                      let authorKey = d["authorKey"] as? String,
                      let created = d["createdAt"] as? TimeInterval,
                      let id = UUID(uuidString: child.key) else { continue }
                notes.append(JarNote(
                    id: id,
                    text: text,
                    authorKey: authorKey,
                    createdAt: Date(timeIntervalSince1970: created)
                ))
            }
            notes.sort { $0.createdAt < $1.createdAt }
            onChange(notes)
        }
    }

    // MARK: - Write

    func addNote(text: String, authorKey: String) {
        let id = UUID()
        notesRef.child(id.uuidString).setValue([
            "text": text,
            "authorKey": authorKey,
            "createdAt": Date().timeIntervalSince1970
        ])
    }

    func setApproval(_ approved: Bool, for authorKey: String) {
        capsuleRef.child("approvals").child(authorKey).setValue(approved)
    }

    func markOpened(at date: Date) {
        capsuleRef.child("openedAt").setValue(date.timeIntervalSince1970)
    }

    func startNewCycle(at date: Date) {
        notesRef.removeValue()
        capsuleRef.setValue([
            "cycleStart": date.timeIntervalSince1970,
            "approvals": [String: Bool](),
            "openedAt": NSNull()
        ])
    }

    func stop() {
        if let capsuleHandle { capsuleRef.removeObserver(withHandle: capsuleHandle) }
        if let notesHandle { notesRef.removeObserver(withHandle: notesHandle) }
        capsuleHandle = nil
        notesHandle = nil
    }
}
