//
//  PeriodRepository.swift
//  Loveyaniask
//
//  Regl alanının tüm verisi için Domain sözleşmesi: ayarlar, kayıtlar, notlar.
//

import Foundation

protocol PeriodRepository {
    func fetchSettings() -> PeriodSettings
    func save(_ settings: PeriodSettings)

    func logs() -> [PeriodLog]
    func addLog(_ log: PeriodLog)
    func deleteLog(id: UUID)

    func notes() -> [DayNote]
    func note(forDayKey dayKey: String) -> DayNote?
    func saveNote(_ note: DayNote)
}
