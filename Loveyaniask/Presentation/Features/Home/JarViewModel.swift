//
//  JarViewModel.swift
//  Loveyaniask
//
//  Anı/düşünce kavanozu mantığı: notlar, doluluk, ekleme/okuma.
//

import Foundation
import Observation

@Observable
final class JarViewModel {
    private(set) var notes: [JarNote] = []
    var showingAdd = false
    var showingRead = false

    let capacity = 12

    private let currentUser: UserProfile
    private let getNotes: GetJarNotesUseCase
    private let addNote: AddJarNoteUseCase
    private let deleteNote: DeleteJarNoteUseCase

    init(
        currentUser: UserProfile,
        getNotes: GetJarNotesUseCase,
        addNote: AddJarNoteUseCase,
        deleteNote: DeleteJarNoteUseCase
    ) {
        self.currentUser = currentUser
        self.getNotes = getNotes
        self.addNote = addNote
        self.deleteNote = deleteNote
        self.notes = getNotes.execute()
    }

    var count: Int { notes.count }
    var isFull: Bool { count >= capacity }

    var sortedNotes: [JarNote] {
        notes.sorted { $0.createdAt > $1.createdAt }
    }

    func reload() {
        notes = getNotes.execute()
    }

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        addNote.execute(text: trimmed, authorKey: currentUser.rawValue)
        reload()
    }

    func delete(_ note: JarNote) {
        deleteNote.execute(id: note.id)
        reload()
    }

    func authorName(_ note: JarNote) -> String {
        (UserProfile(rawValue: note.authorKey) ?? .orhun).firstName
    }

    func dateText(_ note: JarNote) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: note.createdAt)
    }
}
