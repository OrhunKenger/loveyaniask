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
                    .font(.headline)
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
                            .frame(width: 46, height: 46)
                            .background(
                                Circle().fill(selected ? AppColors.primary.opacity(0.18) : AppColors.background)
                            )
                            .overlay(
                                Circle().stroke(selected ? AppColors.primary : .clear, lineWidth: 2)
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
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
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
