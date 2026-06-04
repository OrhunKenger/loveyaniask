//
//  ObservePlacesUseCase.swift
//  Loveyaniask
//
//  Mekanları gerçek zamanlı dinler (Firebase'den her değişimde güncel liste).
//

import Foundation

struct ObservePlacesUseCase {
    private let repository: PlaceRepository

    init(repository: PlaceRepository) {
        self.repository = repository
    }

    func execute(_ onChange: @escaping ([Place]) -> Void) {
        repository.observe(onChange)
    }
}
