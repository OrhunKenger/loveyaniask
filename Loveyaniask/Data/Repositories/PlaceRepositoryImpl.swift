//
//  PlaceRepositoryImpl.swift
//  Loveyaniask
//
//  PlaceRepository implementasyonu: bellekte tutar, değişimde data source'a yazar.
//

import Foundation

final class PlaceRepositoryImpl: PlaceRepository {
    private let localDataSource: PlaceLocalDataSource
    private var cache: [Place]

    init(localDataSource: PlaceLocalDataSource) {
        self.localDataSource = localDataSource
        self.cache = localDataSource.load()
    }

    func all() -> [Place] {
        cache
    }

    func add(_ place: Place) {
        cache.append(place)
        localDataSource.save(cache)
    }

    func update(_ place: Place) {
        if let index = cache.firstIndex(where: { $0.id == place.id }) {
            cache[index] = place
            localDataSource.save(cache)
        }
    }

    func delete(id: UUID) {
        cache.removeAll { $0.id == id }
        localDataSource.save(cache)
    }

    func photoFileName(for id: UUID) -> String? {
        cache.first { $0.id == id }?.photoFileName
    }
}
