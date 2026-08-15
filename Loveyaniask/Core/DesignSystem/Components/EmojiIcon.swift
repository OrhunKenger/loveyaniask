//
//  EmojiIcon.swift
//  Loveyaniask
//
//  Emojileri sistemin kendi (Apple) emojileriyle çizer.
//
//  Bir dönem SVG ikonlara (Fluent Emoji) çevrilmişti; hem görsel olarak
//  beğenilmedi hem de pahalıydı: asset'ler "preserves-vector-representation"
//  ile tutulduğu için her boyutta yeniden rasterize ediliyordu ve ruh hali
//  ızgarası tek ekranda 47 tanesini birden çiziyordu. Artık düz metin —
//  sistem font glifi, cache'li, maliyeti sıfıra yakın.
//

import SwiftUI

struct EmojiIcon: View {
    let emoji: String
    var size: CGFloat

    var body: some View {
        Text(emoji)
            .font(.system(size: size * 0.82))
    }
}
