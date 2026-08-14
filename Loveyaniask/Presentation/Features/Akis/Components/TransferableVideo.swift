//
//  TransferableVideo.swift
//  Loveyaniask
//
//  PhotosPicker'dan seçilen videoyu geçici bir dosyaya kopyalar.
//

import CoreTransferable
import UniformTypeIdentifiers
import Foundation

struct TransferableVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mov")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}
