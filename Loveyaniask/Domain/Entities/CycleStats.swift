//
//  CycleStats.swift
//  Loveyaniask
//
//  Kayıtlı regllerden hesaplanan döngü istatistikleri.
//

import Foundation

struct CycleStats {
    let loggedCount: Int        // kaç regl kaydı var
    let averageCycle: Int?      // ortalama döngü (gün) — en az 2 kayıt gerekir
    let shortestCycle: Int?     // en kısa döngü (gün)
    let longestCycle: Int?      // en uzun döngü (gün)
    let periodLength: Int       // regl süresi (ayardan)
    let regularity: CycleRegularity
    /// Geçmiş regller (yeni → eski) ve o döngünün uzunluğu (varsa).
    let history: [CycleHistoryItem]
}

struct CycleHistoryItem: Identifiable {
    let id: String
    let startDate: Date
    /// Bu regl başlangıcından bir sonrakine kadar geçen gün (tamamlanan döngü).
    /// En yeni kayıt için nil (döngü sürüyor).
    let cycleLength: Int?
}

enum CycleRegularity {
    case unknown    // yeterli veri yok
    case regular    // döngüler birbirine yakın
    case irregular  // döngüler değişken

    var label: String {
        switch self {
        case .unknown: return "—"
        case .regular: return "Düzenli"
        case .irregular: return "Değişken"
        }
    }

    var emoji: String {
        switch self {
        case .unknown: return "🌱"
        case .regular: return "✅"
        case .irregular: return "〽️"
        }
    }
}
