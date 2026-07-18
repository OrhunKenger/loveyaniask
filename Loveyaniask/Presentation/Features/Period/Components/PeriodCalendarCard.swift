//
//  PeriodCalendarCard.swift
//  Loveyaniask
//
//  Aylık regl takvimi. Peş peşe günler BİRLEŞİK bant olarak çizilir (hap gibi):
//  regl bir bant, doğurgan dönem ayrı bant. Gerçek (kayıtlı) regl DOLU renk,
//  tahmini gelecek SOLUK. Bir güne dokununca gün detayı açılır.
//

import SwiftUI

struct PeriodCalendarCard: View {
    @Bindable var viewModel: PeriodViewModel

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let bandRadius: CGFloat = 17
    private let bandHeight: CGFloat = 34

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            monthNavigation

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 2)
                }

                ForEach(Array(viewModel.dayCells().enumerated()), id: \.offset) { index, date in
                    if let date {
                        dayCell(date, index: index)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .glassCard(cornerRadius: 20, padding: 0)
    }

    // MARK: - Ay gezinme

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

    // MARK: - Gün hücresi (bantlı)

    private func dayCell(_ date: Date, index: Int) -> some View {
        let kind = viewModel.kind(for: date)
        let group = viewModel.bandGroup(for: date)
        let isReal = kind == .period && viewModel.isRealPeriodDay(date)
        let today = viewModel.isToday(date)

        // Bandın uçlarını yuvarlamak için komşu günlerin grubu (hafta kenarında kes).
        let columnIndex = index % 7
        let leftGroup = columnIndex == 0 ? -1 : viewModel.bandGroup(for: date.addingDays(-1, calendar))
        let rightGroup = columnIndex == 6 ? -1 : viewModel.bandGroup(for: date.addingDays(1, calendar))
        let roundLeft = leftGroup != group
        let roundRight = rightGroup != group

        return ZStack {
            if group != 0 {
                UnevenRoundedRectangle(
                    topLeadingRadius: roundLeft ? bandRadius : 0,
                    bottomLeadingRadius: roundLeft ? bandRadius : 0,
                    bottomTrailingRadius: roundRight ? bandRadius : 0,
                    topTrailingRadius: roundRight ? bandRadius : 0,
                    style: .continuous
                )
                .fill(bandColor(kind: kind, isReal: isReal))
                .frame(height: bandHeight)
            }

            if today {
                Circle()
                    .stroke(AppColors.textPrimary, lineWidth: 1.5)
                    .frame(width: bandHeight, height: bandHeight)
            }

            Text("\(viewModel.dayNumber(for: date))")
                .font(.system(size: 14, weight: today ? .bold : .regular))
                .foregroundStyle(numberColor(kind: kind, isReal: isReal))
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Renkler

    private func bandColor(kind: CycleDayKind, isReal: Bool) -> Color {
        switch kind {
        case .period: return isReal ? AppColors.period : AppColors.period.opacity(0.30)
        case .ovulation: return AppColors.ovulation.opacity(0.9)
        case .fertile: return AppColors.fertile.opacity(0.28)
        case .none: return .clear
        }
    }

    private func numberColor(kind: CycleDayKind, isReal: Bool) -> Color {
        switch kind {
        case .period: return isReal ? .white : AppColors.period
        case .ovulation: return .white
        case .fertile, .none: return AppColors.textPrimary
        }
    }
}

private extension Date {
    func addingDays(_ days: Int, _ calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
}
