//
//  GetPlacePhotoUseCase.swift
//  Loveyaniask
//

import Foundation

struct GetPlacePhotoUseCase {
    private let photoStore: PlacePhotoStore

    init(photoStore: PlacePhotoStore) {
        self.photoStore = photoStore
    }

    func execute(fileName: String) -> Data? {
        photoStore.loadImageData(named: fileName)
    }
}
