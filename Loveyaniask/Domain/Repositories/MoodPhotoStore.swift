//
//  MoodPhotoStore.swift
//  Loveyaniask
//
//  Ruh hali fotoğraflarının saklanması için Domain sözleşmesi.
//  Domain sadece "bir dosya adı" bilir; nerede/nasıl saklandığı Data katmanının işi.
//

import Foundation

protocol MoodPhotoStore {
    /// Görseli kaydeder, dosya adını döndürür.
    func save(imageData: Data) -> String?
    func loadImageData(named name: String) -> Data?
    func delete(named name: String)
}
