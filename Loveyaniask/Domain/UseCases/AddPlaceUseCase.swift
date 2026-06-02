//
//  AddPlaceUseCase.swift
//  Loveyaniask
//
//  Yeni mekan ekler; fotoğraf varsa önce saklar.
//

import Foundation

struct AddPlaceUseCase {
    private let repository: PlaceRepository
    private let photoStore: PlacePhotoStore

    init(repository: PlaceRepository, photoStore: PlacePhotoStore) {
        self.repository = repository
        self.photoStore = photoStore
    }

    func execute(
        name: String,
        latitude: Double,
        longitude: Double,
        rating: Int,
        note: String,
        dateVisited: Date,
        imageData: Data?
    ) {
        var fileName: String?
        if let imageData {
            fileName = photoStore.save(imageData: imageData)
        }
        let place = Place(
            id: UUID(),
            name: name,
            latitude: latitude,
            longitude: longitude,
            rating: rating,
            note: note,
            dateVisited: dateVisited,
            photoFileName: fileName
        )
        repository.add(place)
    }
}
