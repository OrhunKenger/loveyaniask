//
//  LibraryDetailSheet.swift
//  Loveyaniask
//
//  Öğe detayı: poster, durum geçişi, ikili puan, özet, sil.
//

import SwiftUI

struct LibraryDetailSheet: View {
    @Bindable var viewModel: LibraryViewModel
    let itemId: UUID
    @Environment(\.dismiss) private var dismiss

    private var item: LibraryItem? { viewModel.items.first { $0.id == itemId } }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let item {
                    VStack(spacing: AppSpacing.lg) {
                        PosterImage(url: item.posterURL, kind: item.kind, width: 150)
                            .padding(.top, AppSpacing.md)

                        Text(item.title)
                            .font(.title3.bold())
                            .foregroundStyle(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        statusPicker(item)

                        ratingsCard(item)

                        if !item.overview.isEmpty {
                            Text(item.overview)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button(role: .destructive) {
                            viewModel.delete(item)
                            dismiss()
                        } label: {
                            Label("Kütüphaneden sil", systemImage: "trash")
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.top, AppSpacing.sm)
                    }
                    .padding(AppSpacing.lg)
                } else {
                    Color.clear.onAppear { dismiss() }
                }
            }
            .background(AppColors.background)
            .navigationTitle(item?.kind.label ?? "Detay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
        .presentationDetents([.large, .medium])
    }

    // MARK: - Durum

    private func statusPicker(_ item: LibraryItem) -> some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(LibraryStatus.allCases) { status in
                let selected = item.status == status
                Button {
                    viewModel.setStatus(item, status)
                } label: {
                    Text(status.label(for: item.kind))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selected ? .white : AppColors.textPrimary)
                        .padding(.vertical, AppSpacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(selected ? AppColors.primary : AppColors.surface)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Puanlar

    private func ratingsCard(_ item: LibraryItem) -> some View {
        VStack(spacing: AppSpacing.md) {
            ratingRow(name: "Senin puanın", rating: viewModel.myRating(for: item), interactive: true) { star in
                viewModel.setMyRating(item, rating: star)
            }
            Divider()
            ratingRow(
                name: viewModel.currentUser.partner.firstName,
                rating: viewModel.rating(of: viewModel.currentUser.partner, for: item),
                interactive: false,
                onTap: { _ in }
            )
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func ratingRow(name: String, rating: Int, interactive: Bool, onTap: @escaping (Int) -> Void) -> some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundStyle(star <= rating ? .yellow : AppColors.textSecondary)
                        .onTapGesture {
                            if interactive { onTap(star) }
                        }
                }
            }
        }
    }
}
