//
//  SetPlaceVisitedUseCase.swift
//  Loveyaniask
//
//  Bir mekanı "gittik" olarak işaretler (hayal listesinden gittiklerimize taşır)
//  ya da tersine alır.
//

import Foundation

struct SetPlaceVisitedUseCase {
    private let repository: PlaceRepository

    init(repository: PlaceRepository) {
        self.repository = repository
    }

    func execute(placeId: UUID, visited: Bool, dateVisited: Date) {
        guard var place = repository.all().first(where: { $0.id == placeId }) else { return }
        place.visited = visited
        if visited {
            place.dateVisited = dateVisited
        }
        repository.update(place)
    }
}
