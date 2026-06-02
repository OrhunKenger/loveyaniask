//
//  Symptom.swift
//  Loveyaniask
//
//  Günlük işaretlenebilen belirtiler.
//

import Foundation

enum Symptom: String, CaseIterable, Codable, Identifiable {
    case cramp
    case headache
    case fatigue
    case bloating
    case moodSwing
    case backPain
    case nausea
    case craving

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cramp: return "😖"
        case .headache: return "🤕"
        case .fatigue: return "😴"
        case .bloating: return "🎈"
        case .moodSwing: return "🎭"
        case .backPain: return "🦴"
        case .nausea: return "🤢"
        case .craving: return "🍫"
        }
    }

    var label: String {
        switch self {
        case .cramp: return "Kramp"
        case .headache: return "Baş ağrısı"
        case .fatigue: return "Yorgunluk"
        case .bloating: return "Şişkinlik"
        case .moodSwing: return "Ruh hali"
        case .backPain: return "Bel ağrısı"
        case .nausea: return "Bulantı"
        case .craving: return "Tatlı krizi"
        }
    }
}
