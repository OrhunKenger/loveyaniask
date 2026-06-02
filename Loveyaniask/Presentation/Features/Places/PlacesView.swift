//
//  PlacesView.swift
//  Loveyaniask
//
//  Gidilen mekanlar: üstte harita (pin'ler), altta kart listesi. İkiniz de ekler.
//

import SwiftUI
import MapKit

struct PlacesView: View {
    @State private var viewModel: PlacesViewModel

    init(viewModel: PlacesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    header
                    mapCard
                    if viewModel.places.isEmpty {
                        emptyState
                    } else {
                        placeList
                    }
                }
                .padding(AppSpacing.md)
            }
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            AddPlaceSheet(viewModel: viewModel)
        }
    }

    private var header: some View {
        HStack {
            Text("Gittiğimiz Mekanlar")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button {
                viewModel.showingAdd = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)
            }
        }
    }

    private var mapCard: some View {
        Map(initialPosition: .region(viewModel.initialRegion)) {
            ForEach(viewModel.places) { place in
                Marker(place.name, coordinate: viewModel.coordinate(for: place))
                    .tint(AppColors.primary)
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textSecondary)
            Text("Henüz mekan eklemediniz")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Text("Sağ üstteki + ile ilk mekanınızı ekleyin")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xl)
    }

    private var placeList: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(viewModel.places) { place in
                placeCard(place)
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.delete(place)
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private func placeCard(_ place: Place) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let data = viewModel.photoData(for: place), let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(place.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    stars(place.rating)
                }

                Text(viewModel.dateText(for: place))
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)

                if !place.note.isEmpty {
                    Text(place.note)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private func stars(_ rating: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(star <= rating ? AppColors.primary : AppColors.textSecondary.opacity(0.4))
            }
        }
    }
}
