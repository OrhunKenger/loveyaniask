//
//  MoodEntry.swift
//  Loveyaniask
//
//  Bir günde, bir kişinin ruh hali kaydı (+ opsiyonel fotoğraf).
//

import Foundation

struct MoodEntry: Codable, Identifiable {
    let id: UUID
    let dayKey: String        // "yyyy-MM-dd"
    let partner: Partner
    var mood: Mood?
    var photoFileName: String?
}
