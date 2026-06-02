//
//  DayNote.swift
//  Loveyaniask
//
//  Belirli bir güne ait belirti + not.
//

import Foundation

struct DayNote: Codable, Equatable {
    var dayKey: String
    var symptoms: [Symptom]
    var note: String

    var isEmpty: Bool {
        symptoms.isEmpty && note.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
