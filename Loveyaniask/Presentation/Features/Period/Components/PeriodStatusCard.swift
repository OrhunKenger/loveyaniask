//
//  PeriodStatusCard.swift
//  Loveyaniask
//
//  Bugünün durumu: faz + döngü günü + ilerleme halkası + sonraki regl.
//

import SwiftUI

struct PeriodStatusCard: View {
    let emoji: String
    let statusText: String
    let cycleDay: Int
    let progress: Double
    let nextPeriodText: String
    let daysUntilNext: Int

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text(emoji).font(.title3)
                    Text("\(cycleDay).")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("gün")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .frame(width: 84, height: 84)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Sonraki regl: \(nextPeriodText)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                Text(daysUntilNext == 0 ? "Bugün başlayabilir" : "\(daysUntilNext) gün sonra")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.3), radius: 14, y: 8)
    }
}
