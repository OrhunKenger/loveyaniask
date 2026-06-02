//
//  SetPlaceRatingUseCase.swift
//  Loveyaniask
//
//  Bir kullanıcının bir mekana verdiği puanı ayarlar (varsa günceller).
//

import Foundation

struct SetPlaceRatingUseCase {
    private let repository: PlaceRepository

    init(repository: PlaceRepository) {
        self.repository = repository
    }

    func execute(placeId: UUID, userKey: String, rating: Int) {
        guard var place = repository.all().first(where: { $0.id == placeId }) else { return }
        place.ratings[userKey] = rating
        repository.update(place)
    }
}
