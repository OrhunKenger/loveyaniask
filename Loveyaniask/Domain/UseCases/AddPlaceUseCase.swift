//
//  AddPlaceUseCase.swift
//  Loveyaniask
//
//  Yeni mekan ekler; ekleyen kişinin puanını kaydeder, fotoğraf varsa saklar.
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
        raterKey: String,
        rating: Int,
        note: String,
        dateVisited: Date,
        imageData: Data?
    ) {
        var fileName: String?
        if let imageData {
            fileName = photoStore.save(imageData: imageData)
        }
        var ratings: [String: Int] = [:]
        if rating > 0 {
            ratings[raterKey] = rating
        }
        let place = Place(
            id: UUID(),
            name: name,
            latitude: latitude,
            longitude: longitude,
            ratings: ratings,
            note: note,
            dateVisited: dateVisited,
            photoFileName: fileName
        )
        repository.add(place)
    }
}
