//
//  Mood.swift
//  Loveyaniask
//
//  Seçilebilen ruh halleri. Emoji + Türkçe etiket.
//

import Foundation

enum Mood: String, CaseIterable, Codable, Identifiable {
    case happy
    case loved
    case calm
    case excited
    case tired
    case sad
    case angry
    case anxious
    case sick

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .loved: return "🥰"
        case .calm: return "😌"
        case .excited: return "🤩"
        case .tired: return "😴"
        case .sad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .sick: return "🤒"
        }
    }

    var label: String {
        switch self {
        case .happy: return "Mutlu"
        case .loved: return "Aşık"
        case .calm: return "Huzurlu"
        case .excited: return "Heyecanlı"
        case .tired: return "Yorgun"
        case .sad: return "Üzgün"
        case .angry: return "Kızgın"
        case .anxious: return "Endişeli"
        case .sick: return "Hasta"
        }
    }
}
