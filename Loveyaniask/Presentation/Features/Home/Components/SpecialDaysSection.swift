//
//  SpecialDaysSection.swift
//  Loveyaniask
//
//  Ana sayfada, süre kartının altında: özel günler animasyonlu baloncuklar.
//  Baloncuğa dokununca küçük bir detay sheet'i açılır.
//

import SwiftUI

struct SpecialDaysSection: View {
    @Bindable var viewModel: SpecialDaysViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Özel Günlerimiz")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button {
                    viewModel.startNew()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.lg) {
                    ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                        SpecialDayBubble(
                            emoji: day.emoji,
                            daysRemaining: viewModel.daysRemaining(for: day),
                            title: day.title,
                            index: index
                        )
                        .onTapGesture { viewModel.select(day) }
                        .contextMenu {
                            if !day.isBuiltIn {
                                Button {
                                    viewModel.startEdit(day)
                                } label: {
                                    Label("Düzenle", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    viewModel.delete(day)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, AppSpacing.sm)
                .padding(.horizontal, 4)
            }
        }
        .sheet(item: $viewModel.selectedDay) { day in
            SpecialDayDetailSheet(
                day: day,
                daysRemaining: viewModel.daysRemaining(for: day),
                dateText: viewModel.nextDateText(for: day)
            )
        }
        .sheet(item: $viewModel.formTarget) { target in
            AddSpecialDaySheet(viewModel: viewModel, editing: target.day)
        }
    }
}

private struct SpecialDayBubble: View {
    let emoji: String
    let daysRemaining: Int
    let title: String
    let index: Int

    @State private var floating = false

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: AppColors.primary.opacity(0.35), radius: 10, y: 6)

                VStack(spacing: 1) {
                    Text(emoji)
                        .font(.system(size: 24))
                    Text(daysRemaining == 0 ? "Bugün" : "\(daysRemaining)")
                        .font(.headline)
                        .foregroundStyle(.white)
                    if daysRemaining != 0 {
                        Text("gün")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .offset(y: floating ? -5 : 5)
            .animation(
                .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.25),
                value: floating
            )

            Text(title)
                .font(.caption2)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .frame(width: 92)
        }
        .onAppear { floating = true }
    }
}
