//
//  PeriodStatsCard.swift
//  Loveyaniask
//
//  Döngü istatistikleri: ortalama döngü, regl süresi, kayıt sayısı, düzenlilik
//  ve geçmiş regller. Hepsi kayıtlı reglerden otomatik hesaplanır.
//

import SwiftUI

struct PeriodStatsCard: View {
    let viewModel: PeriodViewModel

    private let columns = [GridItem(.flexible(), spacing: AppSpacing.sm),
                           GridItem(.flexible(), spacing: AppSpacing.sm)]

    var body: some View {
        let stats = viewModel.cycleStats

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Döngü İstatistikleri")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            if stats.loggedCount == 0 {
                emptyState
            } else {
                tiles(stats)

                if stats.loggedCount < 2 {
                    Text("İstatistikler 2. regl kaydından sonra netleşir 🌱")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if !stats.history.isEmpty {
                    Divider().overlay(AppColors.glassStroke)
                    historyList(stats)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, padding: AppSpacing.lg)
    }

    // MARK: - Boş durum

    private var emptyState: some View {
        Text("Henüz regl kaydı yok. İlk kaydından sonra istatistikler burada belirir 🌸")
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Kutucuklar

    private func tiles(_ stats: CycleStats) -> some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
            tile(icon: "🔁", title: "Ort. döngü",
                 value: stats.averageCycle.map { "\($0) gün" } ?? "—")
            tile(icon: "🩸", title: "Regl süresi",
                 value: "\(stats.periodLength) gün")
            tile(icon: "📊", title: "Kayıt",
                 value: "\(stats.loggedCount) döngü")
            tile(icon: stats.regularity.emoji, title: "Düzenlilik",
                 value: stats.regularity.label)
        }
    }

    private func tile(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Text(icon).font(.caption)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(AppColors.glassFill)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Geçmiş

    private func historyList(_ stats: CycleStats) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Geçmiş regller")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(stats.history.prefix(6)) { item in
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(AppColors.period).frame(width: 7, height: 7)
                        Text(viewModel.statDateText(item.startDate))
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    Spacer()
                    Text(item.cycleLength.map { "\($0) günlük döngü" } ?? "Sürüyor")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }
}
