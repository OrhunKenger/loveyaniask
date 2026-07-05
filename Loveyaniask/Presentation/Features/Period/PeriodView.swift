//
//  PeriodView.swift
//  Loveyaniask
//
//  Regl takvimi: bugünün durumu, gerçek kayıt, aylık takvim, günlük notlar.
//  Şevval düzenler/kaydeder, Orhun izler.
//

import SwiftUI

struct PeriodView: View {
    @State private var viewModel: PeriodViewModel
    @State private var showingSettings = false

    let canEdit: Bool

    init(viewModel: PeriodViewModel, canEdit: Bool) {
        _viewModel = State(initialValue: viewModel)
        self.canEdit = canEdit
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            GlowBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header

                    PeriodStatusCard(
                        emoji: viewModel.statusEmoji,
                        statusText: viewModel.statusText,
                        cycleDay: viewModel.currentCycleDay,
                        progress: viewModel.cycleProgress,
                        nextPeriodText: viewModel.nextPeriodDateText,
                        daysUntilNext: viewModel.daysUntilNextPeriod
                    )

                    if canEdit {
                        logButton
                    }

                    calendarCard
                    legend
                }
                .padding(AppSpacing.md)
            }
        }
        .sheet(isPresented: $showingSettings) {
            PeriodSettingsSheet(viewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedDay) { day in
            PeriodDayDetailSheet(viewModel: viewModel, date: day.date, canEdit: canEdit)
        }
    }

    // MARK: - Başlık

    private var header: some View {
        HStack {
            Text("Regl Takvimi")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            if canEdit {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            } else {
                Image(systemName: "lock.fill")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var logButton: some View {
        Button {
            withAnimation(.snappy) { viewModel.logPeriodToday() }
        } label: {
            Label("Bugün reglim başladı", systemImage: "drop.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.period)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Takvim kartı

    private var calendarCard: some View {
        VStack(spacing: AppSpacing.md) {
            monthNavigation

            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }

                ForEach(Array(viewModel.dayCells().enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayView(for: date)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
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

    private func dayView(for date: Date) -> some View {
        let kind = viewModel.kind(for: date)
        let isToday = viewModel.isToday(date)
        let hasNote = viewModel.hasNote(on: date)

        return VStack(spacing: 2) {
            Text("\(viewModel.dayNumber(for: date))")
                .font(.system(size: 15, weight: isToday ? .bold : .regular))
                .foregroundStyle(foreground(for: kind))
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(
                    Circle()
                        .fill(background(for: kind))
                        .frame(width: 34, height: 34)
                )
                .overlay(
                    Circle()
                        .stroke(isToday ? AppColors.textPrimary : .clear, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                )

            Circle()
                .fill(hasNote ? AppColors.ovulation : .clear)
                .frame(width: 4, height: 4)
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.select(date) }
    }

    private func background(for kind: CycleDayKind) -> Color {
        switch kind {
        case .period: return AppColors.period
        case .ovulation: return AppColors.ovulation
        case .fertile: return AppColors.fertile.opacity(0.3)
        case .none: return .clear
        }
    }

    private func foreground(for kind: CycleDayKind) -> Color {
        switch kind {
        case .period, .ovulation: return .white
        case .fertile, .none: return AppColors.textPrimary
        }
    }

    // MARK: - Açıklama

    private var legend: some View {
        HStack(spacing: AppSpacing.md) {
            legendItem(color: AppColors.period, text: "Regl")
            legendItem(color: AppColors.fertile.opacity(0.5), text: "Doğurgan")
            legendItem(color: AppColors.ovulation, text: "Yumurtlama")
        }
        .font(.caption2)
        .foregroundStyle(AppColors.textSecondary)
    }

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
        }
    }
}
