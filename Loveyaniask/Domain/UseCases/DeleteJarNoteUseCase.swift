//
//  DeleteJarNoteUseCase.swift
//  Loveyaniask
//

import Foundation

struct DeleteJarNoteUseCase {
    private let repository: JarNoteRepository

    init(repository: JarNoteRepository) {
        self.repository = repository
    }

    func execute(id: UUID) {
        repository.delete(id: id)
    }
}
