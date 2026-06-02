//
//  PlacePhotoStore.swift
//  Loveyaniask
//
//  Mekan fotoğraflarının saklanması için Domain sözleşmesi.
//

import Foundation

protocol PlacePhotoStore {
    func save(imageData: Data) -> String?
    func loadImageData(named name: String) -> Data?
    func delete(named name: String)
}
