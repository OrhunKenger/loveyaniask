//
//  SpecialDay.swift
//  Loveyaniask
//
//  Özel bir gün (yıldönümü, doğum günü vb.). Yıllık tekrarlayabilir.
//

import Foundation

struct SpecialDay: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var emoji: String
    var repeatsYearly: Bool
    /// Uygulamayla gelen sabit gün mü? (true = silinemez: yıldönümü/doğum günleri)
    var isBuiltIn: Bool = false
}
