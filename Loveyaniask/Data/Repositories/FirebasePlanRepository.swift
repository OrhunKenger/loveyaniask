//
//  FirebasePlanRepository.swift
//  Loveyaniask
//
//  Planların Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  plans/{uuid} -> { title, date, note, remindEnabled, authorKey }
//

import Foundation
import FirebaseDatabase

final class FirebasePlanRepository: PlanRepository {
    private let ref = Database.database().reference().child("plans")
    private var cache: [Plan] = []
    private var onChange: (([Plan]) -> Void)?
    private var handle: DatabaseHandle?

    init() {
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var items: [Plan] = []
            for case let child as DataSnapshot in snapshot.children {
                if let plan = Self.decode(child) { items.append(plan) }
            }
            self.cache = items
            self.onChange?(items)
        }
    }

    func observe(_ onChange: @escaping ([Plan]) -> Void) {
        self.onChange = onChange
        onChange(cache)
    }

    func add(_ plan: Plan) {
        if !cache.contains(where: { $0.id == plan.id }) { cache.append(plan) }
        onChange?(cache)
        ref.child(plan.id.uuidString).setValue(Self.encode(plan))
    }

    func update(_ plan: Plan) {
        if let i = cache.firstIndex(where: { $0.id == plan.id }) { cache[i] = plan }
        onChange?(cache)
        ref.child(plan.id.uuidString).setValue(Self.encode(plan))
    }

    func delete(id: UUID) {
        cache.removeAll { $0.id == id }
        onChange?(cache)
        ref.child(id.uuidString).removeValue()
    }

    private static func encode(_ p: Plan) -> [String: Any] {
        [
            "title": p.title,
            "date": p.date.timeIntervalSince1970,
            "note": p.note,
            "remindEnabled": p.remindEnabled,
            "authorKey": p.authorKey
        ]
    }

    private static func decode(_ snap: DataSnapshot) -> Plan? {
        guard let d = snap.value as? [String: Any],
              let id = UUID(uuidString: snap.key),
              let title = d["title"] as? String,
              let ts = d["date"] as? TimeInterval else { return nil }
        let note = (d["note"] as? String) ?? ""
        let remind = (d["remindEnabled"] as? Bool) ?? true
        let author = (d["authorKey"] as? String) ?? "orhun"
        return Plan(
            id: id, title: title, date: Date(timeIntervalSince1970: ts),
            note: note, remindEnabled: remind, authorKey: author
        )
    }
}
