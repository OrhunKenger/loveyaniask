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
    case nervous
    case relieved
    case melting
    // 2. genişleme
    case wild
    case energetic
    case hyperactive
    case playful
    case pampered
    case passionate
    case connected
    case tranquil
    case satisfied
    case curious
    case disappointed
    case lonely
    case exhausted
    case shocked
    case hurt
    case overwhelmed
    case restless
    case safe
    case sleepy
    case hungry

    var id: String { rawValue }

    /// Kartta gösterim sırası (olumludan olumsuza doğru, akıcı bir düzen).
    static var displayOrder: [Mood] {
        [
            .happy, .loved, .romantic, .passionate, .melting, .affectionate, .connected, .pampered, .playful, .wild,
            .calm, .tranquil, .relieved, .satisfied, .safe, .excited, .energetic, .hyperactive, .motivated,
            .proud, .longing, .shy, .surprised, .shocked, .curious, .unsure,
            .confused, .neutral, .hungry, .bored, .sleepy, .tired, .exhausted, .sad,
            .lonely, .disappointed, .tearful, .hurt, .nervous, .restless, .stressed, .overwhelmed, .anxious, .angry,
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
        case .nervous: return "😬"
        case .relieved: return "😮‍💨"
        case .melting: return "🫠"
        case .wild: return "🤪"
        case .energetic: return "⚡️"
        case .hyperactive: return "🐿️"
        case .playful: return "😜"
        case .pampered: return "😽"
        case .passionate: return "🔥"
        case .connected: return "🔗"
        case .tranquil: return "🧘"
        case .satisfied: return "😌"
        case .curious: return "🧐"
        case .disappointed: return "😞"
        case .lonely: return "🥹"
        case .exhausted: return "🥱"
        case .shocked: return "😨"
        case .hurt: return "🩹"
        case .overwhelmed: return "🫣"
        case .restless: return "😖"
        case .safe: return "🛡️"
        case .sleepy: return "😪"
        case .hungry: return "😋"
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
        case .nervous: return "Gergin"
        case .relieved: return "Rahatlamış"
        case .melting: return "Eriyorum"
        case .wild: return "Çılgın"
        case .energetic: return "Enerjik"
        case .hyperactive: return "Hiperaktif"
        case .playful: return "Komik"
        case .pampered: return "Şımarık"
        case .passionate: return "Tutkulu"
        case .connected: return "Bağlı"
        case .tranquil: return "Sakin"
        case .satisfied: return "Tatmin olmuş"
        case .curious: return "Meraklı"
        case .disappointed: return "Hayal kırıklığına uğramış"
        case .lonely: return "Yalnız"
        case .exhausted: return "Bitkin"
        case .shocked: return "Şok olmuş"
        case .hurt: return "İncinmiş"
        case .overwhelmed: return "Bunalmış"
        case .restless: return "Huzursuz"
        case .safe: return "Güvende"
        case .sleepy: return "Uykum var"
        case .hungry: return "Aç"
        }
    }
}
