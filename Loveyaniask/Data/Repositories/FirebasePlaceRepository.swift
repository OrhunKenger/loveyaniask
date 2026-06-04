//
//  FirebasePlaceRepository.swift
//  Loveyaniask
//
//  Mekanların Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//  places/items/{uuid} -> { name, latitude, longitude, ratings, note, dateVisited, visited, photoFileName? }
//  NOT: fotoğraflar şimdilik cihazda yerel (FilePlacePhotoStore); sadece dosya adı senkronlanır.
//

import Foundation
import FirebaseDatabase

final class FirebasePlaceRepository: PlaceRepository {
    private let ref = Database.database().reference().child("places").child("items")
    private var cache: [Place] = []
    private var onChange: (([Place]) -> Void)?
    private var handle: DatabaseHandle?

    init() {
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var items: [Place] = []
            for case let child as DataSnapshot in snapshot.children {
                if let place = Self.decode(child) { items.append(place) }
            }
            self.cache = items
            self.onChange?(items)
        }
    }

    func observe(_ onChange: @escaping ([Place]) -> Void) {
        self.onChange = onChange
        onChange(cache)
    }

    func all() -> [Place] { cache }

    func add(_ place: Place) {
        if !cache.contains(where: { $0.id == place.id }) { cache.append(place) }
        onChange?(cache)
        ref.child(place.id.uuidString).setValue(Self.encode(place))
    }

    func update(_ place: Place) {
        if let i = cache.firstIndex(where: { $0.id == place.id }) { cache[i] = place }
        onChange?(cache)
        ref.child(place.id.uuidString).setValue(Self.encode(place))
    }

    func delete(id: UUID) {
        cache.removeAll { $0.id == id }
        onChange?(cache)
        ref.child(id.uuidString).removeValue()
    }

    func photoFileName(for id: UUID) -> String? {
        cache.first { $0.id == id }?.photoFileName
    }

    // MARK: - Kodlama

    private static func encode(_ p: Place) -> [String: Any] {
        var d: [String: Any] = [
            "name": p.name,
            "latitude": p.latitude,
            "longitude": p.longitude,
            "note": p.note,
            "dateVisited": p.dateVisited.timeIntervalSince1970,
            "visited": p.visited,
            "ratings": p.ratings
        ]
        if let file = p.photoFileName { d["photoFileName"] = file }
        return d
    }

    private static func decode(_ snap: DataSnapshot) -> Place? {
        guard let d = snap.value as? [String: Any],
              let id = UUID(uuidString: snap.key),
              let name = d["name"] as? String,
              let lat = d["latitude"] as? Double,
              let lon = d["longitude"] as? Double else { return nil }

        var ratings: [String: Int] = [:]
        if let raw = d["ratings"] as? [String: Any] {
            for (key, value) in raw {
                if let n = value as? Int { ratings[key] = n }
            }
        }
        let note = (d["note"] as? String) ?? ""
        let dateVisited = (d["dateVisited"] as? TimeInterval)
            .map { Date(timeIntervalSince1970: $0) } ?? Date()
        let visited = (d["visited"] as? Bool) ?? true
        let photo = d["photoFileName"] as? String

        return Place(
            id: id, name: name, latitude: lat, longitude: lon,
            ratings: ratings, note: note, dateVisited: dateVisited,
            photoFileName: photo, visited: visited
        )
    }
}
