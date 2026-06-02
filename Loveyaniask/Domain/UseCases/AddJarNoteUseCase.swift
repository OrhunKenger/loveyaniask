//
//  AddJarNoteUseCase.swift
//  Loveyaniask
//

import Foundation

struct AddJarNoteUseCase {
    private let repository: JarNoteRepository

    init(repository: JarNoteRepository) {
        self.repository = repository
    }

    func execute(text: String, authorKey: String) {
        let note = JarNote(id: UUID(), text: text, authorKey: authorKey, createdAt: Date())
        repository.add(note)
    }
}
