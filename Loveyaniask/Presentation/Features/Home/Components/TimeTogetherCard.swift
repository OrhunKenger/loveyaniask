//
//  TimeTogetherCard.swift
//  Loveyaniask
//
//  Ana sayfanın üstündeki canlı sayaç kartı.
//  TimelineView ile her saniye yeniden çizilir → saniye saniye ilerler.
//

import SwiftUI

struct TimeTogetherCard: View {
    let viewModel: HomeViewModel
    /// Home sekmesi görünür değilken saniyelik yeniden çizimi durdurur.
    var isActive: Bool = true

    var body: some View {
        if isActive {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                content(for: viewModel.timeTogether(at: context.date))
            }
        } else {
            // Arka plandayken statik anlık görüntü (TimelineView tetiklenmez).
            content(for: viewModel.timeTogether(at: Date()))
        }
    }

    private func content(for time: TimeTogether) -> some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "heart.fill")
                    .font(.subheadline)
                Text("Birlikteyiz")
                    .font(.headline)
            }
            .foregroundStyle(.white.opacity(0.95))

            HStack(alignment: .top, spacing: AppSpacing.xs) {
                unit(value: time.days, label: "Gün")
                separator
                unit(value: time.hours, label: "Saat", padded: true)
                separator
                unit(value: time.minutes, label: "Dakika", padded: true)
                separator
                unit(value: time.seconds, label: "Saniye", padded: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.md)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: AppColors.primary.opacity(0.35), radius: 20, x: 0, y: 10)
    }

    private func unit(value: Int, label: String, padded: Bool = false) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(padded ? String(format: "%02d", value) : "\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    private var separator: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 34)
    }
}

/// Üst satırda, profil butonunun solundaki küçük canlı sayaç.
/// Tek satır: ♥ 123g 04:15:32 — saniye saniye işler.
struct TimeTogetherCompact: View {
    let viewModel: HomeViewModel
    var isActive: Bool = true

    var body: some View {
        if isActive {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                content(for: viewModel.timeTogether(at: context.date))
            }
        } else {
            content(for: viewModel.timeTogether(at: Date()))
        }
    }

    private func content(for time: TimeTogether) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "heart.fill")
                .font(.caption2)
                .foregroundStyle(AppColors.primary)
            Text("\(time.days)g")
                .foregroundStyle(AppColors.textPrimary)
            Text(String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds))
                .foregroundStyle(AppColors.textSecondary)
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .font(.footnote.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(AppColors.glassFill))
        .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
    }
}
