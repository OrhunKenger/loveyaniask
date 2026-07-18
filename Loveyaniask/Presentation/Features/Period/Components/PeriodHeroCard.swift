//
//  PeriodHeroCard.swift
//  Loveyaniask
//
//  Regl sayfasının üst kartı ("yüzü"): faz + bölgeli döngü çubuğu + gün bilgisi.
//  Temiz bilgi odaklı: döngünün neresindeyiz tek bakışta görünür.
//

import SwiftUI

struct PeriodHeroCard: View {
    let viewModel: PeriodViewModel

    var body: some View {
        let accent = viewModel.currentPhase.accent

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Faz
            HStack(spacing: AppSpacing.sm) {
                Text(viewModel.statusEmoji)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(accent.opacity(0.18)))
                    .overlay(Circle().stroke(accent.opacity(0.45), lineWidth: 1))
                Text(viewModel.statusText)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            // Bölgeli döngü çubuğu + bugün işareti
            PeriodCycleBar(
                kinds: viewModel.cycleDayKinds(),
                currentIndex: viewModel.currentCycleIndex
            )

            // Renk açıklaması (çubuğun hemen altında)
            HStack(spacing: AppSpacing.md) {
                legendItem(color: AppColors.period, text: "Regl")
                legendItem(color: AppColors.fertile.opacity(0.5), text: "Doğurgan")
                legendItem(color: AppColors.ovulation, text: "Yumurtlama")
                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(AppColors.textSecondary)

            // Alt bilgi
            HStack {
                Text("\(viewModel.currentCycleDay). gün")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(nextText)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .glassCard(cornerRadius: 22, padding: AppSpacing.lg)
        .shadow(color: accent.opacity(0.22), radius: 18, x: 0, y: 8)
    }

    private var nextText: String {
        let days = viewModel.daysUntilNextPeriod
        if days == 0 { return "Regl bugün başlayabilir" }
        return "Sonraki regl: \(viewModel.nextPeriodDateText) · \(days) gün"
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
        }
    }
}

/// Döngünün tamamını gösteren bölgeli yatay çubuk. Her gün bir hücre; renk
/// o günün türünü (regl/doğurgan/yumurtlama/normal) verir. Bugünün hücresi
/// çerçeveli ve üstünde küçük bir işaretle vurgulanır.
private struct PeriodCycleBar: View {
    let kinds: [CycleDayKind]
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(kinds.enumerated()), id: \.offset) { index, kind in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(color(for: kind))
                    .frame(height: 16)
                    .overlay {
                        if index == currentIndex {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(AppColors.textPrimary, lineWidth: 2)
                        }
                    }
                    .overlay(alignment: .top) {
                        if index == currentIndex {
                            Circle()
                                .fill(AppColors.textPrimary)
                                .frame(width: 7, height: 7)
                                .offset(y: -11)
                        }
                    }
            }
        }
        .padding(.top, 11) // üstteki "bugün" noktası kırpılmasın
    }

    private func color(for kind: CycleDayKind) -> Color {
        switch kind {
        case .period: return AppColors.period
        case .ovulation: return AppColors.ovulation
        case .fertile: return AppColors.fertile.opacity(0.5)
        case .none: return AppColors.textSecondary.opacity(0.18)
        }
    }
}
