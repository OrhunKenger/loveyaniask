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
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    calendarCard
                    legend
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
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
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
                Text(meMood?.emoji ?? "·")
                    .font(.system(size: 15))
                    .opacity(meMood == nil ? 0.25 : 1)
                Text(partnerMood?.emoji ?? "·")
                    .font(.system(size: 15))
                    .opacity(partnerMood == nil ? 0.25 : 1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isToday ? AppColors.primary.opacity(0.10) : Color.black.opacity(0.02))
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

    // MARK: - Açıklama

    private var legend: some View {
        HStack(spacing: AppSpacing.lg) {
            Text("👈 \(viewModel.meLabel)")
            Text("\(viewModel.partnerLabel) 👉")
        }
        .font(.caption2)
        .foregroundStyle(AppColors.textSecondary)
    }
}

