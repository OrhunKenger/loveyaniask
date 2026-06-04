//
//  JarApproveSheet.swift
//  Loveyaniask
//
//  Kavanoz açılmaya hazır olduğunda açma onayı ekranı.
//  İkiniz de onaylayınca kavanoz otomatik açılır ve bu ekran kapanır.
//

import SwiftUI

struct JarApproveSheet: View {
    let viewModel: JarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Spacer()

                MemoryJarView(count: viewModel.count, isReady: true, scale: 0.85)

                Text("Açılmaya hazır! 🎉")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.primary)

                Text("Açmak için ikinizin de onayı gerekli — yan yanayken birlikte açın.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)

                HStack(spacing: AppSpacing.md) {
                    approvalChip(name: "Sen", approved: viewModel.myApproved)
                    approvalChip(name: viewModel.partnerName, approved: viewModel.partnerApproved)
                }

                Spacer()

                Button {
                    viewModel.toggleApproval()
                } label: {
                    Text(viewModel.myApproved ? "Onayını geri al" : "Açmayı onaylıyorum")
                        .font(.headline)
                        .foregroundStyle(viewModel.myApproved ? AppColors.primary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(viewModel.myApproved
                                    ? AppColors.primary.opacity(0.12)
                                    : AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                if viewModel.myApproved && !viewModel.partnerApproved {
                    Text("\(viewModel.partnerName) bekleniyor…")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Kavanozu Aç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .onChange(of: viewModel.isOpened) { _, opened in
                // İkisi de onaylayıp kavanoz açılınca bu ekranı kapat.
                if opened { dismiss() }
            }
        }
    }

    private func approvalChip(name: String, approved: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: approved ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(approved ? .green : AppColors.textSecondary)
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface)
        .clipShape(Capsule())
    }
}
