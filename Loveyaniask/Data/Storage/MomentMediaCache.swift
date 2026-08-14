//
//  MomentMediaCache.swift
//  Loveyaniask
//
//  Firebase Storage'dan inen an medyalarını diske önbellekler (storagePath -> yerel dosya).
//  Caches dizininde tutulur: bulutta zaten yedeği olduğu için sistem baskı altında silebilir.
//

import Foundation

final class MomentMediaCache {
    private let fileManager = FileManager.default

    private lazy var directory: URL = {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("MomentMedia", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()

    func localURL(forStoragePath path: String) -> URL {
        let name = path.replacingOccurrences(of: "/", with: "_")
        return directory.appendingPathComponent(name)
    }

    func isCached(forStoragePath path: String) -> Bool {
        fileManager.fileExists(atPath: localURL(forStoragePath: path).path)
    }
}
