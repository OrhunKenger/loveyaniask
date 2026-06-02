//
//  PeriodRepositoryImpl.swift
//  Loveyaniask
//
//  PeriodRepository implementasyonu: ayarlar + kayıtlar + notlar.
//

import Foundation

final class PeriodRepositoryImpl: PeriodRepository {
    private let localDataSource: PeriodLocalDataSource
    private var cachedLogs: [PeriodLog]
    private var cachedNotes: [DayNote]

    init(localDataSource: PeriodLocalDataSource) {
        self.localDataSource = localDataSource
        self.cachedLogs = localDataSource.loadLogs()
        self.cachedNotes = localDataSource.loadNotes()
    }

    // MARK: - Ayarlar

    func fetchSettings() -> PeriodSettings {
        localDataSource.load()
    }

    func save(_ settings: PeriodSettings) {
        localDataSource.save(settings)
    }

    // MARK: - Kayıtlar

    func logs() -> [PeriodLog] {
        cachedLogs
    }

    func addLog(_ log: PeriodLog) {
        cachedLogs.append(log)
        localDataSource.saveLogs(cachedLogs)
    }

    func deleteLog(id: UUID) {
        cachedLogs.removeAll { $0.id == id }
        localDataSource.saveLogs(cachedLogs)
    }

    // MARK: - Notlar

    func notes() -> [DayNote] {
        cachedNotes
    }

    func note(forDayKey dayKey: String) -> DayNote? {
        cachedNotes.first { $0.dayKey == dayKey }
    }

    func saveNote(_ note: DayNote) {
        if let index = cachedNotes.firstIndex(where: { $0.dayKey == note.dayKey }) {
            if note.isEmpty {
                cachedNotes.remove(at: index)
            } else {
                cachedNotes[index] = note
            }
        } else if !note.isEmpty {
            cachedNotes.append(note)
        }
        localDataSource.saveNotes(cachedNotes)
    }
}
