//
//  MemoryJarSection.swift
//  Loveyaniask
//
//  Ana sayfadaki aylık kavanoz kartı.
//  Toplama → (ay dolunca) açılmaya hazır → iki onay → açıldı → oku & yeni döngü.
//

import SwiftUI

struct MemoryJarSection: View {
    @Bindable var viewModel: JarViewModel

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Birbirimiz Hakkında 💭")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            MemoryJarView(count: viewModel.count, isReady: viewModel.isReady)

            statusContent

            if viewModel.canAddNote {
                Button {
                    viewModel.showingAdd = true
                } label: {
                    Label("Not Ekle", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .sheet(isPresented: $viewModel.showingAdd) {
            AddJarNoteSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingReveal) {
            JarRevealSheet(viewModel: viewModel)
        }
    }

    // MARK: - Duruma göre alt içerik

    @ViewBuilder
    private var statusContent: some View {
        switch viewModel.state {
        case .collecting:
            VStack(spacing: AppSpacing.xs) {
                Text(viewModel.daysLeft == 0
                     ? "Bugün açılabilir hale geliyor"
                     : "Açılmasına \(viewModel.daysLeft) gün kaldı")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                Text("İçine birbiriniz hakkında düşündüklerinizi atın. Ay dolunca, yan yanayken birlikte açacaksınız.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

        case .ready:
            VStack(spacing: AppSpacing.sm) {
                Text("Açılmaya hazır! 🎉")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.primary)
                Text("Açmak için ikinizin de onayı gerekli — yan yanayken birlikte açın.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)

                HStack(spacing: AppSpacing.md) {
                    approvalChip(name: "Sen", approved: viewModel.myApproved)
                    approvalChip(name: viewModel.partnerName, approved: viewModel.partnerApproved)
                }

                Button {
                    viewModel.toggleApproval()
                } label: {
                    Text(viewModel.myApproved ? "Onayını geri al" : "Açmayı onaylıyorum")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.myApproved ? AppColors.primary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(viewModel.myApproved
                                    ? AppColors.primary.opacity(0.12)
                                    : AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

        case .opened:
            VStack(spacing: AppSpacing.sm) {
                Text("Kavanoz açıldı! 💖")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColors.primary)
                Button {
                    viewModel.showingReveal = true
                } label: {
                    Label("Aç ve Oku (\(viewModel.count))", systemImage: "book.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private func approvalChip(name: String, approved: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: approved ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(approved ? .green : AppColors.textSecondary)
            Text(name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 6)
        .background(AppColors.background)
        .clipShape(Capsule())
    }
}
