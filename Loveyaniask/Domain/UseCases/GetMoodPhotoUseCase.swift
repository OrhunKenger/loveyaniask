//
//  GetMoodPhotoUseCase.swift
//  Loveyaniask
//
//  Dosya adından fotoğraf verisini getirir.
//

import Foundation

struct GetMoodPhotoUseCase {
    private let photoStore: MoodPhotoStore

    init(photoStore: MoodPhotoStore) {
        self.photoStore = photoStore
    }

    func execute(fileName: String) -> Data? {
        photoStore.loadImageData(named: fileName)
    }
}
