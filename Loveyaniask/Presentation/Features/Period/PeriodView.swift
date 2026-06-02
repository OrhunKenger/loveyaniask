//
//  PeriodView.swift
//  Loveyaniask
//
//  Regl takvimi ekranı: aylık ızgara, özet tahminler ve ayar butonu.
//

import SwiftUI

struct PeriodView: View {
    @State private var viewModel: PeriodViewModel
    @State private var showingSettings = false

    init(viewModel: PeriodViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    summaryCard
                    calendarCard
                    legend
                }
                .padding(AppSpacing.md)
            }
        }
        .sheet(isPresented: $showingSettings) {
            PeriodSettingsSheet(viewModel: viewModel)
        }
    }

    // MARK: - Başlık

    private var header: some View {
        HStack {
            Text("Regl Takvimi")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title3)
                    .foregroundStyle(AppColors.primary)
            }
        }
    }

    // MARK: - Özet kart

    private var summaryCard: some View {
        HStack(spacing: AppSpacing.md) {
            summaryItem(
                title: "Döngü günü",
                value: "\(viewModel.currentCycleDay).",
                subtitle: "gün"
            )

            Divider().frame(height: 44)

            summaryItem(
                title: "Sonraki regl",
                value: viewModel.nextPeriodDateText,
                subtitle: "\(viewModel.daysUntilNextPeriod) gün sonra"
            )
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func summaryItem(title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
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
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
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

    private func dayView(for date: Date) -> some View {
        let kind = viewModel.kind(for: date)
        let isToday = viewModel.isToday(date)

        return Text("\(viewModel.dayNumber(for: date))")
            .font(.system(size: 15, weight: isToday ? .bold : .regular))
            .foregroundStyle(foreground(for: kind))
            .frame(maxWidth: .infinity)
            .frame(height: 38)
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

    // MARK: - Açıklama (legend)

    private var legend: some View {
        HStack(spacing: AppSpacing.lg) {
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

#Preview {
    let dataSource = UserDefaultsPeriodDataSource()
    let repository = PeriodRepositoryImpl(localDataSource: dataSource)
    return PeriodView(viewModel: PeriodViewModel(
        getSettings: GetPeriodSettingsUseCase(repository: repository),
        saveSettings: SavePeriodSettingsUseCase(repository: repository)
    ))
}
