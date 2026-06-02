//
//  PeriodRepository.swift
//  Loveyaniask
//
//  Regl ayarlarının okunup yazılması için Domain sözleşmesi (protokol).
//

import Foundation

protocol PeriodRepository {
    func fetchSettings() -> PeriodSettings
    func save(_ settings: PeriodSettings)
}
