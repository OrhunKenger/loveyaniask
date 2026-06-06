//
//  LibraryUseCases.swift
//  Loveyaniask
//
//  Kütüphane için observe / ekle / güncelle / sil.
//

import Foundation

struct ObserveLibraryUseCase {
    private let repository: LibraryRepository
    init(repository: LibraryRepository) { self.repository = repository }
    func execute(_ onChange: @escaping ([LibraryItem]) -> Void) {
        repository.observe(onChange)
    }
}

struct AddLibraryItemUseCase {
    private let repository: LibraryRepository
    init(repository: LibraryRepository) { self.repository = repository }
    func execute(title: String, kind: LibraryKind, posterURL: String?, overview: String, addedBy: String) {
        let item = LibraryItem(
            id: UUID(),
            title: title,
            kind: kind,
            status: .want,
            posterURL: posterURL,
            overview: overview,
            ratings: [:],
            note: "",
            addedBy: addedBy,
            addedAt: Date()
        )
        repository.add(item)
    }
}

struct UpdateLibraryItemUseCase {
    private let repository: LibraryRepository
    init(repository: LibraryRepository) { self.repository = repository }
    func execute(_ item: LibraryItem) { repository.update(item) }
}

struct DeleteLibraryItemUseCase {
    private let repository: LibraryRepository
    init(repository: LibraryRepository) { self.repository = repository }
    func execute(id: UUID) { repository.delete(id: id) }
}
