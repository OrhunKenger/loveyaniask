//
//  PeriodLog.swift
//  Loveyaniask
//
//  Gerçekte kaydedilmiş bir regl başlangıcı. Tahminler bunlara göre düzelir.
//

import Foundation

struct PeriodLog: Codable, Identifiable, Equatable {
    let id: UUID
    var startDate: Date
}
