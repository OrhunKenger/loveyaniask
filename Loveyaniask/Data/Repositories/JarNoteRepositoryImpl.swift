//
//  JarNoteRepositoryImpl.swift
//  Loveyaniask
//

import Foundation

final class JarNoteRepositoryImpl: JarNoteRepository {
    private let localDataSource: JarNoteLocalDataSource
    private var cache: [JarNote]

    init(localDataSource: JarNoteLocalDataSource) {
        self.localDataSource = localDataSource
        self.cache = localDataSource.load()
    }

    func all() -> [JarNote] {
        cache
    }

    func add(_ note: JarNote) {
        cache.append(note)
        localDataSource.save(cache)
    }

    func delete(id: UUID) {
        cache.removeAll { $0.id == id }
        localDataSource.save(cache)
    }
}
