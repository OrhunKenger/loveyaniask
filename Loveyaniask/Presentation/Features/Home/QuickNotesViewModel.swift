//
//  QuickNotesViewModel.swift
//  Loveyaniask
//
//  Ana sayfadaki "Hızlı Not" bölümünün mantığı (Firebase, gerçek zamanlı).
//  Serbest notlar: ekle / sil. En yeni üstte.
//

import Foundation
import Observation

@Observable
final class QuickNotesViewModel {
    private(set) var notes: [QuickNote] = []
    var showingAdd = false

    private let currentUser: UserProfile
    private let repository: any QuickNoteRepository

    init(currentUser: UserProfile, repository: any QuickNoteRepository) {
        self.currentUser = currentUser
        self.repository = repository
        repository.observeNotes { [weak self] notes in
            self?.notes = notes
        }
    }

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        repository.addNote(text: trimmed, authorKey: currentUser.rawValue)
    }

    func delete(_ note: QuickNote) {
        repository.deleteNote(id: note.id)
    }

    func authorName(_ note: QuickNote) -> String {
        (UserProfile(rawValue: note.authorKey) ?? .orhun).firstName
    }

    func dateText(_ note: QuickNote) -> String {
        Self.dateFormatter.string(from: note.createdAt)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMM"
        return f
    }()
}
