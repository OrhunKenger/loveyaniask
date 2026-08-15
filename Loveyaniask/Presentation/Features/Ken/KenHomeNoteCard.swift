//
//  KenHomeNoteCard.swift
//  Loveyaniask
//
//  Ana sayfada Ken'in bıraktığı not (ken/homeNote — bulut routine'i üretir).
//
//  Kartta Ken'in kendisi ÇİZİLMEZ: uygulamada tek bir Ken var ve o zaten
//  ekranda dolaşıyor (bkz. KenStage). İkinci bir Ken "tek adet" kuralını
//  bozar. Burada sadece imzası (🐾) duruyor.
//  Karta dokununca Ken gelip selam veriyor.
//

import SwiftUI

struct KenHomeNoteCard: View {
    let companion: KenCompanion

    var body: some View {
        if let note = companion.homeNote, note.isFresh {
            content(note)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func content(_ note: KenNote) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text("🐾")
                .font(.subheadline)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text("Ken'in Notu")
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
