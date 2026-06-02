//
//  GetJarNotesUseCase.swift
//  Loveyaniask
//

import Foundation

struct GetJarNotesUseCase {
    private let repository: JarNoteRepository

    init(repository: JarNoteRepository) {
        self.repository = repository
    }

    func execute() -> [JarNote] {
        repository.all()
    }
}
