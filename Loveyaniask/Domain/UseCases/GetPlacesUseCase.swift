//
//  GetPlacesUseCase.swift
//  Loveyaniask
//

import Foundation

struct GetPlacesUseCase {
    private let repository: PlaceRepository

    init(repository: PlaceRepository) {
        self.repository = repository
    }

    func execute() -> [Place] {
        repository.all().sorted { $0.dateVisited > $1.dateVisited }
    }
}
