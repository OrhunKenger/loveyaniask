//
//  FirebaseJarRepository.swift
//  Loveyaniask
//
//  Kavanozun Firebase Firestore implementasyonu — gerçek zamanlı senkron.
//  Yapı:
//    jar/current        -> { cycleStart, approvals, openedAt }
//    jarNotes/{uuid}    -> { text, authorKey, createdAt }
//

import Foundation
import FirebaseFirestore

final class FirebaseJarRepository: JarRepository {
    private let db = Firestore.firestore()
    private var capsuleListener: ListenerRegistration?
    private var notesListener: ListenerRegistration?

    private var capsuleDoc: DocumentReference {
        db.collection("jar").document("current")
    }
    private var notesCol: CollectionReference {
        db.collection("jarNotes")
    }

    // MARK: - Observe

    func observeCapsule(_ onChange: @escaping (JarCapsule) -> Void) {
        capsuleListener = capsuleDoc.addSnapshotListener { [weak self] snapshot, _ in
            guard let self, let snapshot else { return }

            // İlk açılış: belge yoksa varsayılan döngüyü oluştur.
            guard snapshot.exists, let data = snapshot.data() else {
                self.capsuleDoc.setData([
                    "cycleStart": Timestamp(date: Date()),
                    "approvals": [String: Bool](),
                    "openedAt": NSNull()
                ])
                return
            }

            let cycleStart = (data["cycleStart"] as? Timestamp)?.dateValue() ?? Date()
            let approvals = (data["approvals"] as? [String: Bool]) ?? [:]
            let openedAt = (data["openedAt"] as? Timestamp)?.dateValue()
            onChange(JarCapsule(cycleStart: cycleStart, approvals: approvals, openedAt: openedAt))
        }
    }

    func observeNotes(_ onChange: @escaping ([JarNote]) -> Void) {
        notesListener = notesCol
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let notes: [JarNote] = docs.compactMap { doc in
                    let d = doc.data()
                    guard let text = d["text"] as? String,
                          let authorKey = d["authorKey"] as? String,
                          let ts = d["createdAt"] as? Timestamp,
                          let id = UUID(uuidString: doc.documentID) else { return nil }
                    return JarNote(id: id, text: text, authorKey: authorKey, createdAt: ts.dateValue())
                }
                onChange(notes)
            }
    }

    // MARK: - Write

    func addNote(text: String, authorKey: String) {
        let id = UUID()
        notesCol.document(id.uuidString).setData([
            "text": text,
            "authorKey": authorKey,
            "createdAt": Timestamp(date: Date())
        ])
    }

    func setApproval(_ approved: Bool, for authorKey: String) {
        // merge:true iç içe map'i alan bazında birleştirir (diğer onayı silmez).
        capsuleDoc.setData(["approvals": [authorKey: approved]], merge: true)
    }

    func markOpened(at date: Date) {
        capsuleDoc.setData(["openedAt": Timestamp(date: date)], merge: true)
    }

    func startNewCycle(at date: Date) {
        // Tüm notları topluca sil.
        notesCol.getDocuments { [weak self] snapshot, _ in
            guard let self else { return }
            let batch = self.db.batch()
            snapshot?.documents.forEach { batch.deleteDocument($0.reference) }
            batch.commit()
        }
        // Döngüyü gerçek açılış tarihinden yeniden başlat.
        capsuleDoc.setData([
            "cycleStart": Timestamp(date: date),
            "approvals": [String: Bool](),
            "openedAt": NSNull()
        ])
    }

    func stop() {
        capsuleListener?.remove()
        notesListener?.remove()
        capsuleListener = nil
        notesListener = nil
    }
}
