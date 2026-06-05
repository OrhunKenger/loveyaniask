//
//  FirebasePeriodRepository.swift
//  Loveyaniask
//
//  Regl takviminin Firebase Realtime Database implementasyonu — gerçek zamanlı senkron.
//    period/settings         -> { lastPeriodStart, cycleLength, periodLength, reminderEnabled, reminderDaysBefore }
//    period/logs/{uuid}      -> { startDate }
//    period/notes/{dayKey}   -> { symptoms: [String], note }
//

import Foundation
import FirebaseDatabase

final class FirebasePeriodRepository: PeriodRepository {
    private let root = Database.database().reference().child("period")

    private var cachedSettings: PeriodSettings = .default
    private var cachedLogs: [PeriodLog] = []
    private var cachedNotes: [DayNote] = []
    private var onChange: (() -> Void)?

    init() {
        root.child("settings").observe(.value) { [weak self] snapshot in
            guard let self else { return }
            if let d = snapshot.value as? [String: Any] {
                self.cachedSettings = Self.decodeSettings(d)
            }
            self.onChange?()
        }
        root.child("logs").observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var logs: [PeriodLog] = []
            for case let child as DataSnapshot in snapshot.children {
                if let d = child.value as? [String: Any],
                   let id = UUID(uuidString: child.key),
                   let ts = d["startDate"] as? TimeInterval {
                    logs.append(PeriodLog(id: id, startDate: Date(timeIntervalSince1970: ts)))
                }
            }
            self.cachedLogs = logs
            self.onChange?()
        }
        root.child("notes").observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var notes: [DayNote] = []
            for case let child as DataSnapshot in snapshot.children {
                guard let d = child.value as? [String: Any] else { continue }
                let symptoms = (d["symptoms"] as? [Any])?.compactMap { ($0 as? String).flatMap(Symptom.init(rawValue:)) } ?? []
                let note = (d["note"] as? String) ?? ""
                notes.append(DayNote(dayKey: child.key, symptoms: symptoms, note: note))
            }
            self.cachedNotes = notes
            self.onChange?()
        }
    }

    func observe(_ onChange: @escaping () -> Void) {
        self.onChange = onChange
        onChange()
    }

    // MARK: - Ayarlar

    func fetchSettings() -> PeriodSettings { cachedSettings }

    func save(_ settings: PeriodSettings) {
        cachedSettings = settings
        onChange?()
        root.child("settings").setValue([
            "lastPeriodStart": settings.lastPeriodStart.timeIntervalSince1970,
            "cycleLength": settings.cycleLength,
            "periodLength": settings.periodLength,
            "reminderEnabled": settings.reminderEnabled,
            "reminderDaysBefore": settings.reminderDaysBefore
        ])
    }

    // MARK: - Kayıtlar

    func logs() -> [PeriodLog] { cachedLogs }

    func addLog(_ log: PeriodLog) {
        if !cachedLogs.contains(where: { $0.id == log.id }) { cachedLogs.append(log) }
        onChange?()
        root.child("logs").child(log.id.uuidString).setValue(["startDate": log.startDate.timeIntervalSince1970])
    }

    func deleteLog(id: UUID) {
        cachedLogs.removeAll { $0.id == id }
        onChange?()
        root.child("logs").child(id.uuidString).removeValue()
    }

    // MARK: - Notlar

    func notes() -> [DayNote] { cachedNotes }

    func note(forDayKey dayKey: String) -> DayNote? {
        cachedNotes.first { $0.dayKey == dayKey }
    }

    func saveNote(_ note: DayNote) {
        let ref = root.child("notes").child(note.dayKey)
        if let index = cachedNotes.firstIndex(where: { $0.dayKey == note.dayKey }) {
            if note.isEmpty { cachedNotes.remove(at: index) } else { cachedNotes[index] = note }
        } else if !note.isEmpty {
            cachedNotes.append(note)
        }
        onChange?()
        if note.isEmpty {
            ref.removeValue()
        } else {
            ref.setValue([
                "symptoms": note.symptoms.map { $0.rawValue },
                "note": note.note
            ])
        }
    }

    private static func decodeSettings(_ d: [String: Any]) -> PeriodSettings {
        var s = PeriodSettings.default
        if let ts = d["lastPeriodStart"] as? TimeInterval { s.lastPeriodStart = Date(timeIntervalSince1970: ts) }
        if let c = d["cycleLength"] as? Int { s.cycleLength = c }
        if let p = d["periodLength"] as? Int { s.periodLength = p }
        if let r = d["reminderEnabled"] as? Bool { s.reminderEnabled = r }
        if let rb = d["reminderDaysBefore"] as? Int { s.reminderDaysBefore = rb }
        return s
    }
}
