//
//  QuickNoteRepository.swift
//  Loveyaniask
//
//  Hızlı not veri sınırı (Domain boundary). Gerçek zamanlı dinleme + yazma.
//  Implementasyonu Data katmanında (Firebase) yapılır.
//

import Foundation

protocol QuickNoteRepository {
    /// Notları canlı dinler (en yeni üstte sıralı gelir).
    func observeNotes(_ onChange: @escaping ([QuickNote]) -> Void)
    func addNote(text: String, authorKey: String)
    func deleteNote(id: UUID)
    /// Dinleyiciyi bırak.
    func stop()
}
