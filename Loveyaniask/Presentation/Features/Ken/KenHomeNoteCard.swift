//
//  KenHomeNoteCard.swift
//  Loveyaniask
//
//  Ana sayfada Ken'in bıraktığı not (ken/homeNote — bulut routine'i üretir).
//  Solunda küçük, canlı bir Ken duruyor: nefes alıyor, göz kırpıyor, kuyruğunu
//  sallıyor. Ken'in sadece rastgele belirdiği anlarda değil, ana sayfada da
//  sürekli "orada" olmasını sağlayan tek yer burası.
//  Karta dokununca Ken gerçekten ortaya çıkıyor.
//

import SwiftUI

struct KenHomeNoteCard: View {
    let companion: KenCompanion
    /// Ana sayfa görünürken mi? Değilse minik Ken'in hareket motoru duruyor.
    var isActive: Bool = true

    var body: some View {
        if let note = companion.homeNote, note.isFresh {
            content(note)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func content(_ note: KenNote) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Sürekli ekranda durduğu için düşük kare hızı: sadece nefes alıp
            // göz kırpıyor, 20 fps bunun için fazlasıyla yeterli.
            KenCharacterView(behavior: .sit, tone: companion.moodTone, isVisible: isActive, fps: 20)
                .frame(width: 42, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text("🐾 Ken'in Notu")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.primary)
                Text(note.text)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, padding: AppSpacing.md)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            companion.trigger(.greet)
        }
    }
}
