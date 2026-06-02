//
//  MoodRepository.swift
//  Loveyaniask
//
//  Ruh hali kayıtlarının okunup yazılması için Domain sözleşmesi.
//

import Foundation

protocol MoodRepository {
    func allEntries() -> [MoodEntry]
    func entry(dayKey: String, partner: Partner) -> MoodEntry?
    func upsert(_ entry: MoodEntry)
}
