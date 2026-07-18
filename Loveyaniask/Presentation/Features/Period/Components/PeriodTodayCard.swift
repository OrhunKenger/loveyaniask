//
//  PeriodTodayCard.swift
//  Loveyaniask
//
//  "Günün Mesajı": faza göre kendiliğinden değişen sıcak mesaj + ipucu.
//  Mesaj her iki tarafta da görünür (Şevval'i yalnız bırakmama). İpucu bakan
//  kişiye göre uyarlanır: Şevval'e kendine bakım, Orhun'a "bugün ne yapmalı".
//

import SwiftUI

struct PeriodTodayCard: View {
    let viewModel: PeriodViewModel
    /// Bakan kişi Şevval mi? (Düzenleme yetkisi olan taraf.)
    let isSevval: Bool

    var body: some View {
        let content = viewModel.todayContent
        let phase = viewModel.currentPhase
        let accent = phase.accent

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Faz rozeti
            HStack(spacing: 6) {
                Text(phase.emoji)
                    .font(.subheadline)
                Text("\(phase.name) · \(viewModel.currentCycleDay). gün")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accent)
            }

            // Günün sıcak mesajı — solunda ince aksan çizgisi (alıntı hissi)
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(accent.opacity(0.85))
                    .frame(width: 3)
                Text(content.sevvalMessage)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .fixedSize(horizontal: false, vertical: true)

            // İpucu (bakan kişiye göre)
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(accent)
                    .padding(.top, 2)
                Text(isSevval ? content.sevvalTip : content.orhunTip)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 22, padding: AppSpacing.lg)
        .shadow(color: accent.opacity(0.14), radius: 14, x: 0, y: 6)
    }
}
