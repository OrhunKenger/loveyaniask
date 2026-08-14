//
//  EmojiIcon.swift
//  Loveyaniask
//
//  Emoji'leri modern SVG ikonlara (Fluent Emoji, Flat stil) çevirir.
//  Haritada karşılığı olmayan bir emoji gelirse (ör. eski/serbest veri),
//  sessizce düz metin emojiye geri döner — hiçbir zaman boş kalmaz.
//

import SwiftUI

private let emojiAssetMap: [String: String] = [
    "😊": "mood_happy",
    "🥰": "mood_loved",
    "😌": "mood_calm",
    "🤩": "mood_excited",
    "😴": "mood_tired",
    "😢": "mood_sad",
    "😠": "mood_angry",
    "😰": "mood_anxious",
    "🤒": "mood_sick",
    "😘": "mood_romantic",
    "🤗": "mood_affectionate",
    "💪": "mood_motivated",
    "😎": "mood_proud",
    "🥺": "mood_longing",
    "😳": "mood_shy",
    "😲": "mood_surprised",
    "🤔": "mood_unsure",
    "😵‍💫": "mood_confused",
    "😐": "mood_neutral",
    "😑": "mood_bored",
    "🥲": "mood_tearful",
    "😩": "mood_stressed",
    "😤": "mood_irritated",
    "😒": "mood_resentful",
    "😬": "mood_nervous",
    "😮‍💨": "mood_relieved",
    "🫠": "mood_melting",
    "🤪": "mood_wild",
    "⚡️": "mood_energetic",
    "🐿️": "mood_hyperactive",
    "😜": "mood_playful",
    "😽": "mood_pampered",
    "🔥": "mood_passionate",
    "🔗": "mood_connected",
    "🧘": "mood_tranquil",
    "🧐": "mood_curious",
    "😞": "mood_disappointed",
    "🥹": "mood_lonely",
    "🥱": "mood_exhausted",
    "😨": "mood_shocked",
    "🩹": "mood_hurt",
    "🫣": "mood_overwhelmed",
    "😖": "mood_restless",
    "🛡️": "mood_safe",
    "😪": "mood_sleepy",
    "😋": "mood_hungry",
    "🩸": "phase_menstrual",
    "🌱": "phase_follicular",
    "🌼": "phase_fertile",
    "🥚": "phase_ovulation",
    "🌙": "phase_luteal",
    "💧": "phase_pms",
    "🎬": "library_film",
    "📺": "library_dizi",
    "📚": "library_kitap",
    "🤕": "symptom_headache",
    "🎈": "symptom_bloating",
    "🎭": "symptom_moodSwing",
    "🦴": "symptom_backPain",
    "🤢": "symptom_nausea",
    "🍫": "symptom_craving",
    "🎉": "specialday_00",
    "❤️": "specialday_01",
    "🎂": "specialday_02",
    "💍": "specialday_03",
    "✈️": "specialday_04",
    "🌹": "specialday_05",
    "🥂": "specialday_06",
    "🎁": "specialday_07",
    "🌟": "specialday_09",
    "🏖️": "specialday_10",
    "🎶": "specialday_11",
    "💖": "specialday_14",
]

struct EmojiIcon: View {
    let emoji: String
    var size: CGFloat

    var body: some View {
        if let assetName = emojiAssetMap[emoji] {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Text(emoji)
                .font(.system(size: size * 0.82))
        }
    }
}
