//
//  Plan.swift
//  Loveyaniask
//
//  Yaklaşan ortak plan (randevu, buluşma, etkinlik). Tarih + saatli.
//

import Foundation

struct Plan: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date          // tarih + saat
    var note: String
    var remindEnabled: Bool
    var authorKey: String    // UserProfile.rawValue
}
