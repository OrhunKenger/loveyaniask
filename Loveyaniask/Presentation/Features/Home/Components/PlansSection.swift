//
//  PlansSection.swift
//  Loveyaniask
//
//  Ana sayfada "Yaklaşan Planlar" akışı: en yakın üstte, geri sayım rozetli.
//

import SwiftUI

struct PlansSection: View {
    @Bindable var viewModel: PlansViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Yaklaşan Planlar") { viewModel.startNew() }

            if viewModel.plans.isEmpty {
                Text("Henüz plan yok — + ile ekleyin (randevu, buluşma, etkinlik)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.plans) { plan in
                        planRow(plan)
                    }
                }
            }
        }
        .sheet(item: $viewModel.formTarget) { target in
            AddPlanSheet(viewModel: viewModel, editing: target.plan)
        }
    }

    private func planRow(_ plan: Plan) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text(viewModel.countdownText(for: plan))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(width: 60, height: 54)
                .background(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(plan.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Text(viewModel.dateText(for: plan))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                if !plan.note.isEmpty {
                    Text(plan.note)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if !plan.remindEnabled {
                Image(systemName: "bell.slash")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .glassCard(cornerRadius: 16, padding: AppSpacing.sm)
        .contextMenu {
            Button {
                viewModel.startEdit(plan)
            } label: {
                Label("Düzenle", systemImage: "pencil")
            }
            Button(role: .destructive) {
                viewModel.delete(plan)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}
