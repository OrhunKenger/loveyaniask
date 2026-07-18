//
//  Mood.swift
//  Loveyaniask
//
//  Seçilebilen ruh halleri. Emoji + Türkçe etiket.
//  NOT: Eski case'lerin rawValue'ları AYNI kalmalı (Firebase'deki geçmiş
//  kayıtlar bunlarla eşleşiyor). Yeni haller sona eklenir.
//

import Foundation

enum Mood: String, CaseIterable, Codable, Identifiable {
    // Mevcut (rawValue'ları değiştirme!)
    case happy
    case loved
    case calm
    case excited
    case tired
    case sad
    case angry
    case anxious
    case sick
    // Yeni eklenenler
    case romantic
    case affectionate
    case motivated
    case proud
    case longing
    case shy
    case surprised
    case unsure
    case confused
    case neutral
    case bored
    case tearful
    case stressed
    case irritated
    case resentful
    case excitedNervous
    case nervous
    case relieved
    case melting

    var id: String { rawValue }

    /// Kartta gösterim sırası (olumludan olumsuza doğru, akıcı bir düzen).
    static var displayOrder: [Mood] {
        [
            .happy, .loved, .romantic, .melting, .affectionate,
            .calm, .relieved, .excited, .excitedNervous, .motivated,
            .proud, .longing, .shy, .surprised, .unsure,
            .confused, .neutral, .bored, .tired, .sad,
            .tearful, .nervous, .stressed, .anxious, .angry,
            .irritated, .resentful, .sick,
        ]
    }

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
        case .romantic: return "😘"
        case .affectionate: return "🤗"
        case .motivated: return "💪"
        case .proud: return "😎"
        case .longing: return "🥺"
        case .shy: return "😳"
        case .surprised: return "😲"
        case .unsure: return "🤔"
        case .confused: return "😵‍💫"
        case .neutral: return "😐"
        case .bored: return "😑"
        case .tearful: return "🥲"
        case .stressed: return "😩"
        case .irritated: return "😤"
        case .resentful: return "😒"
        case .excitedNervous: return "🫨"
        case .nervous: return "😬"
        case .relieved: return "😮‍💨"
        case .melting: return "🫠"
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
        case .romantic: return "Romantik"
        case .affectionate: return "Sevecen"
        case .motivated: return "Motive"
        case .proud: return "Gururlu"
        case .longing: return "Özlemiş"
        case .shy: return "Utangaç"
        case .surprised: return "Şaşkın"
        case .unsure: return "Kararsız"
        case .confused: return "Kafası karışık"
        case .neutral: return "Nötr"
        case .bored: return "Sıkılmış"
        case .tearful: return "Ağlamaklı"
        case .stressed: return "Stresli"
        case .irritated: return "Sinirli"
        case .resentful: return "Küskün"
        case .excitedNervous: return "Heyecandan"
        case .nervous: return "Gergin"
        case .relieved: return "Rahatlamış"
        case .melting: return "Eriyorum"
        }
    }
}
