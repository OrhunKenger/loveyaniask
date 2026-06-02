//
//  FileMoodPhotoStore.swift
//  Loveyaniask
//
//  Fotoğrafları cihazın Documents/MoodPhotos klasörüne kaydeder.
//

import Foundation

final class FileMoodPhotoStore: MoodPhotoStore {
    private let fileManager = FileManager.default

    private var directory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("MoodPhotos", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func save(imageData: Data) -> String? {
        let name = UUID().uuidString + ".jpg"
        let url = directory.appendingPathComponent(name)
        do {
            try imageData.write(to: url)
            return name
        } catch {
            return nil
        }
    }

    func loadImageData(named name: String) -> Data? {
        let url = directory.appendingPathComponent(name)
        return try? Data(contentsOf: url)
    }

    func delete(named name: String) {
        let url = directory.appendingPathComponent(name)
        try? fileManager.removeItem(at: url)
    }
}
