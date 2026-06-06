//
//  WishlistView.swift
//  Loveyaniask
//
//  Gitmek İstediğimiz Mekanlar (hayal listesi). Aynı PlacesViewModel'i paylaşır.
//  Dropdown'dan arayıp eklersiniz; "Gittik ✓" deyince Gittiğimiz Yerler'e geçer.
//  Ekleme butonu kavanoz gibi sayfada yüzer ve sürüklenebilir.
//

import SwiftUI

struct WishlistView: View {
    @State private var viewModel: PlacesViewModel
    @State private var showingAdd = false

    init(viewModel: PlacesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if viewModel.wishlistPlaces.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: AppSpacing.md) {
                                ForEach(viewModel.wishlistPlaces) { place in
                                    card(place)
                                }
                            }
                            .padding(AppSpacing.md)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                addButton
                    .padding(AppSpacing.lg)
            }
            .background(AppColors.background)
            .navigationTitle("Gitmek İstediğimiz")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddPlaceSheet(viewModel: viewModel, wishlist: true)
            }
        }
    }

    // MARK: - Yüzen ekleme butonu (sabit, sağ alt)

    private var addButton: some View {
        Button {
            showingAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(AppColors.primary)
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 10, y: 6)
        }
    }

    // MARK: - Kart

    private func card(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let data = viewModel.photoData(for: place),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            HStack(alignment: .top) {
                Image(systemName: "signpost.right.fill")
                    .foregroundStyle(AppColors.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    if !place.note.isEmpty {
                        Text(place.note)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Spacer()
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    viewModel.markVisited(place)
                }
            } label: {
                Label("Gittik ✓", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(place)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "signpost.right.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppColors.primary)
            Text("Henüz gitmek istediğimiz yer yok")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("+ butonuyla gitmek istediğiniz yerleri ekleyin")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
