//
//  DeletePlaceUseCase.swift
//  Loveyaniask
//
//  Mekanı ve varsa fotoğrafını siler.
//

import Foundation

struct DeletePlaceUseCase {
    private let repository: PlaceRepository
    private let photoStore: PlacePhotoStore

    init(repository: PlaceRepository, photoStore: PlacePhotoStore) {
        self.repository = repository
        self.photoStore = photoStore
    }

    func execute(id: UUID) {
        if let fileName = repository.photoFileName(for: id) {
            photoStore.delete(named: fileName)
        }
        repository.delete(id: id)
    }
}
