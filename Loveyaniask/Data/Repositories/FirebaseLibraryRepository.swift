//
//  FirebaseLibraryRepository.swift
//  Loveyaniask
//
//  Kütüphanenin Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  library/{uuid} -> { title, kind, status, posterURL?, overview, ratings, note, addedBy, addedAt }
//

import Foundation
import FirebaseDatabase

final class FirebaseLibraryRepository: LibraryRepository {
    private let ref = Database.database().reference().child("library")
    private var cache: [LibraryItem] = []
    private var onChange: (([LibraryItem]) -> Void)?
    private var handle: DatabaseHandle?

    init() {
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var items: [LibraryItem] = []
            for case let child as DataSnapshot in snapshot.children {
                if let item = Self.decode(child) { items.append(item) }
            }
            self.cache = items
            self.onChange?(items)
        }
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }

    func observe(_ onChange: @escaping ([LibraryItem]) -> Void) {
        self.onChange = onChange
        onChange(cache)
    }

    func add(_ item: LibraryItem) {
        if !cache.contains(where: { $0.id == item.id }) { cache.append(item) }
        onChange?(cache)
        ref.child(item.id.uuidString).setValue(Self.encode(item))
    }

    func update(_ item: LibraryItem) {
        if let i = cache.firstIndex(where: { $0.id == item.id }) { cache[i] = item }
        onChange?(cache)
        ref.child(item.id.uuidString).setValue(Self.encode(item))
    }

    func delete(id: UUID) {
        cache.removeAll { $0.id == id }
        onChange?(cache)
        ref.child(id.uuidString).removeValue()
    }

    private static func encode(_ item: LibraryItem) -> [String: Any] {
        var d: [String: Any] = [
            "title": item.title,
            "kind": item.kind.rawValue,
            "status": item.status.rawValue,
            "overview": item.overview,
            "ratings": item.ratings,
            "note": item.note,
            "addedBy": item.addedBy,
            "addedAt": item.addedAt.timeIntervalSince1970
        ]
        if let poster = item.posterURL { d["posterURL"] = poster }
        return d
    }

    private static func decode(_ snap: DataSnapshot) -> LibraryItem? {
        guard let d = snap.value as? [String: Any],
              let id = UUID(uuidString: snap.key),
              let title = d["title"] as? String,
              let kind = (d["kind"] as? String).flatMap(LibraryKind.init(rawValue:)) else { return nil }

        let status = (d["status"] as? String).flatMap(LibraryStatus.init(rawValue:)) ?? .want
        var ratings: [String: Int] = [:]
        if let raw = d["ratings"] as? [String: Any] {
            for (key, value) in raw { if let n = value as? Int { ratings[key] = n } }
        }
        let addedAt = (d["addedAt"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) } ?? Date()

        return LibraryItem(
            id: id,
            title: title,
            kind: kind,
            status: status,
            posterURL: d["posterURL"] as? String,
            overview: (d["overview"] as? String) ?? "",
            ratings: ratings,
            note: (d["note"] as? String) ?? "",
            addedBy: (d["addedBy"] as? String) ?? "orhun",
            addedAt: addedAt
        )
    }
}
