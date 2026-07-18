//
//  PeriodPmsBanner.swift
//  Loveyaniask
//
//  PMS penceresi uyarısı: PMS aktifken ya da 1-3 gün içinde başlarken belirir,
//  diğer zamanlarda görünmez. Metin bakan kişiye göre uyarlanır.
//

import SwiftUI

struct PeriodPmsBanner: View {
    let viewModel: PeriodViewModel
    let isSevval: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(isActive ? "💧" : "🌙")
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.period.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColors.period.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var isActive: Bool { viewModel.isPMSActive }

    private var title: String {
        if isActive {
            return isSevval ? "PMS dönemindesin" : "Şevval PMS döneminde"
        }
        let days = viewModel.daysUntilPMS
        return "PMS yaklaşıyor · \(days) gün sonra"
    }

    private var subtitle: String {
        if isActive {
            return isSevval
                ? "Duyguların yoğun olabilir — kendine nazik ol 🤍"
                : "Bugün ekstra sabır ve şefkat günü, yanında ol 🤍"
        }
        return isSevval
            ? "Kendine hazırlan, bu günlerde yavaşlamak serbest 🌙"
            : "Sabırlı ve anlayışlı olmaya hazırlan, küçük jestler işe yarar 🌙"
    }
}
