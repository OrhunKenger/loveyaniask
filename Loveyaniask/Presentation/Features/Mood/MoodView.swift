//
//  MoodView.swift
//  Loveyaniask
//
//  "Bugün nasıl hissediyorsun?" ekranı: geniş aylık takvim,
//  her günde ikinizin ruh hali emojisi. Güne dokununca düzenleme açılır.
//

import SwiftUI

struct MoodView: View {
    @State private var viewModel: MoodViewModel

    init(viewModel: MoodViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            GlowBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    calendarCard
                    legend
                    analysisCard
                }
                .padding(AppSpacing.md)
            }
        }
        .sheet(item: $viewModel.selectedDay) { day in
            MoodDayEditorSheet(viewModel: viewModel, date: day.date)
        }
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Bugün nasıl hissediyorsun?")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            Text("Bugünün ruh halini seç")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Takvim

    private var calendarCard: some View {
        VStack(spacing: AppSpacing.md) {
            monthNavigation

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }

                ForEach(Array(viewModel.dayCells().enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 60)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .glassCard(cornerRadius: 20, padding: 0)
    }

    private var monthNavigation: some View {
        HStack {
            Button {
                withAnimation(.snappy) { viewModel.goToPreviousMonth() }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            Text(viewModel.monthTitle)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button {
                withAnimation(.snappy) { viewModel.goToNextMonth() }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let meMood = viewModel.mood(for: date, partner: .me)
        let partnerMood = viewModel.mood(for: date, partner: .partner)
        let isToday = viewModel.isToday(date)

        return VStack(spacing: 3) {
            Text("\(viewModel.dayNumber(for: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 2) {
                moodDot(meMood)
                moodDot(partnerMood)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isToday ? AppColors.primary.opacity(0.16) : AppColors.glassFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isToday ? AppColors.primary : .clear, lineWidth: 1.2)
        )
        .contentShape(Rectangle())
        .opacity(viewModel.isToday(date) ? 1 : (viewModel.isFuture(date) ? 0.35 : 0.72))
        .onTapGesture {
            // Bugün düzenlenir, geçmiş günler salt-okunur açılır; gelecek kapalı.
            if !viewModel.isFuture(date) {
                viewModel.select(date)
            }
        }
    }

    @ViewBuilder
    private func moodDot(_ mood: Mood?) -> some View {
        if let mood {
            EmojiIcon(emoji: mood.emoji, size: 15)
        } else {
            Text("·")
                .font(.system(size: 15))
                .opacity(0.25)
        }
    }

    // MARK: - Açıklama

    private var legend: some View {
        HStack(spacing: AppSpacing.lg) {
            Text("👈 \(viewModel.meLabel)")
            Text("\(viewModel.partnerLabel) 👉")
        }
        .font(.caption2)
        .foregroundStyle(AppColors.textSecondary)
    }

    // MARK: - AI Analiz

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppColors.primary)
                Text("Ruh Hali Analizi")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            if let analysis = viewModel.analysis {
                Text(analysis.text)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(Self.relativeFormatter.localizedString(for: analysis.generatedAt, relativeTo: Date()))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("Henüz analiz yok. Ruh haliniz değiştikçe burada otomatik bir değerlendirme belirecek.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, padding: AppSpacing.lg)
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "tr_TR")
        return f
    }()
}

