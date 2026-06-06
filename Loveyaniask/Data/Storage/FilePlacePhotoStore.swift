//
//  FilePlacePhotoStore.swift
//  Loveyaniask
//
//  Mekan fotoğraflarını Documents/PlacePhotos klasörüne kaydeder.
//

import Foundation

final class FilePlacePhotoStore: PlacePhotoStore {
    private let fileManager = FileManager.default
    // Tekrarlanan disk okumalarını önlemek için bellek önbelleği.
    private let cache = NSCache<NSString, NSData>()

    // Dizin bir kez hesaplanır (her çağrıda dosya sistemi kontrolü yapılmaz).
    private lazy var directory: URL = {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("PlacePhotos", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()

    func save(imageData: Data) -> String? {
        let name = UUID().uuidString + ".jpg"
        let url = directory.appendingPathComponent(name)
        // Kaydetmeden önce küçült; başarısızsa orijinali yaz.
        let dataToWrite = ImageDownsampler.downsampledJPEG(from: imageData) ?? imageData
        do {
            try dataToWrite.write(to: url)
            cache.setObject(dataToWrite as NSData, forKey: name as NSString)
            return name
        } catch {
            return nil
        }
    }

    func loadImageData(named name: String) -> Data? {
        if let cached = cache.object(forKey: name as NSString) {
            return cached as Data
        }
        let url = directory.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: url) else { return nil }
        cache.setObject(data as NSData, forKey: name as NSString)
        return data
    }

    func delete(named name: String) {
        cache.removeObject(forKey: name as NSString)
        let url = directory.appendingPathComponent(name)
        try? fileManager.removeItem(at: url)
    }
}
