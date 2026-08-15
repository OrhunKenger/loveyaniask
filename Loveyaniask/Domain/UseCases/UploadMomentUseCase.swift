//
//  UploadMomentUseCase.swift
//  Loveyaniask
//

import Foundation

struct UploadMomentUseCase {
    private let repository: MomentRepository

    init(repository: MomentRepository) {
        self.repository = repository
    }

    func execute(mediaType: MomentMediaType, fileURL: URL, completion: @escaping (Error?) -> Void) {
        repository.upload(mediaType: mediaType, fileURL: fileURL, completion: completion)
    }
}
