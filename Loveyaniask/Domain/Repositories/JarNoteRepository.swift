//
//  JarNoteRepository.swift
//  Loveyaniask
//
//  Kavanoz notlarının okunup yazılması için Domain sözleşmesi.
//

import Foundation

protocol JarNoteRepository {
    func all() -> [JarNote]
    func add(_ note: JarNote)
    func delete(id: UUID)
}
