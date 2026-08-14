//
//  KenNote.swift
//  Loveyaniask
//
//  Ken'in ana sayfaya bıraktığı kısa not. Bulut routine'i (ken/homeNote)
//  tarafından, veriler değiştikçe yeniden üretilir.
//

import Foundation

struct KenNote: Equatable {
    let text: String
    let generatedAt: Date

    /// Notun ne kadar süre "taze" sayılacağı — bunu geçince ana sayfada
    /// gösterilmiyor, çünkü eskimiş bir not Ken'i canlı değil unutulmuş gösterir.
    private static let freshness: TimeInterval = 36 * 60 * 60

    var isFresh: Bool {
        Date().timeIntervalSince(generatedAt) < Self.freshness
    }
}
