//
//  SpecialDayDetailSheet.swift
//  Loveyaniask
//
//  Baloncuğa dokununca açılan küçük detay sheet'i: kaç gün kaldığını gösterir.
//

import SwiftUI

struct SpecialDayDetailSheet: View {
    let day: SpecialDay
    let daysRemaining: Int
    let dateText: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text(day.emoji)
                .font(.system(size: 56))

            Text(day.title)
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text(daysRemaining == 0 ? "Bugün! 🎉" : "\(daysRemaining) gün kaldı")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primary)

            Text(dateText)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}
