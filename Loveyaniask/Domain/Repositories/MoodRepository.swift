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
    /// Ruh hali kayıtlarını gerçek zamanlı dinler.
    func observe(_ onChange: @escaping ([MoodEntry]) -> Void)
}
