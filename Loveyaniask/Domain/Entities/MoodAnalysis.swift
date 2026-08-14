//
//  MoodAnalysis.swift
//  Loveyaniask
//
//  Zamanlanmış AI analizinin en son sonucu (moodMeta/lastChangedAt değiştikçe
//  bulut routine'i tarafından üretilir).
//

import Foundation

struct MoodAnalysis: Equatable {
    let text: String
    let generatedAt: Date
}
