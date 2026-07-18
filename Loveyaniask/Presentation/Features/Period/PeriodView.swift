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

    var body: some View {
        ZStack {
            GlowBackground()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header

                    PeriodHeroCard(viewModel: viewModel)

                    if viewModel.showsPMSWarning {
                        PeriodPmsBanner(viewModel: viewModel, isSevval: canEdit)
                    }

                    PeriodTodayCard(viewModel: viewModel, isSevval: canEdit)

                    if canEdit {
                        logButton
                    }

                    PeriodCalendarCard(viewModel: viewModel)

                    PeriodStatsCard(viewModel: viewModel)
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

}
