//
//  MoodHomeSection.swift
//  Loveyaniask
//
//  Ana sayfada bugünün ruh hali kartı: emojilere TEK DOKUNUŞLA kendi halini seç,
//  partnerinkini gör. Takvim ikonuna dokununca tam aylık takvim açılır.
//

import SwiftUI

struct MoodHomeSection: View {
    @Bindable var viewModel: MoodViewModel
    @State private var showingCalendar = false

    private var today: Date { Date() }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Bugün nasıl hissediyorsun?")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button {
                    showingCalendar = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }

            // Hızlı seçim — emojilere tek dokunuş
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(Mood.allCases) { mood in
                        let selected = viewModel.mood(for: today, partner: .me) == mood
                        Text(mood.emoji)
                            .font(.system(size: 28))
                            .frame(width: 48, height: 48)
                            .background(
                                Circle().fill(selected ? AppColors.primary.opacity(0.22) : AppColors.glassFill)
                            )
                            .overlay(
                                Circle().stroke(selected ? AppColors.primary : AppColors.glassStroke, lineWidth: selected ? 2 : 1)
                            )
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    viewModel.setMood(date: today, partner: .me, mood: mood)
                                }
                            }
                    }
                }
                .padding(.horizontal, 2)
            }

            // Partnerin bugünü
            HStack(spacing: 8) {
                Text("\(viewModel.title(for: .partner)):")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                if let mood = viewModel.mood(for: today, partner: .partner) {
                    Text("\(mood.emoji) \(mood.label)")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    Text("henüz paylaşmadı 🫥")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        }
        .glassCard(cornerRadius: 20, padding: AppSpacing.lg)
        .sheet(isPresented: $showingCalendar) {
            NavigationStack {
                MoodView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Kapat") { showingCalendar = false }
                        }
                    }
            }
            .presentationDetents([.large, .medium])
            .presentationDragIndicator(.visible)
        }
    }
}
