//
//  PlacesListSheet.swift
//  Loveyaniask
//
//  Haritanın üstünde açılan bottom sheet: gittiğimiz yerler puana veya
//  tarihe göre sıralı, numaralı bir liste halinde. Bir satıra dokununca
//  o mekanın balon kartı (düzenleme/puan) haritada açılır.
//

import SwiftUI

private enum PlacesSortMode: String, CaseIterable {
    case rating = "Puana göre"
    case date = "Tarihe göre"
}

struct PlacesListSheet: View {
    var viewModel: PlacesViewModel
    /// Bir mekan seçilince (düzenlemek için) çağrılır — sheet'i kapatıp
    /// haritada balon kartı açmak için kullanılır.
    var onSelect: (Place) -> Void

    @State private var sortMode: PlacesSortMode = .rating

    private var sortedPlaces: [Place] {
        switch sortMode {
        case .rating:
            return viewModel.visitedPlaces.sorted { $0.averageRating > $1.averageRating }
        case .date:
            return viewModel.visitedPlaces.sorted { $0.dateVisited > $1.dateVisited }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sortedPlaces.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(Array(sortedPlaces.enumerated()), id: \.element.id) { index, place in
                                Button {
                                    onSelect(place)
                                } label: {
                                    row(index: index + 1, place: place)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle("Gittiğimiz Yerler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Sırala", selection: $sortMode) {
                        ForEach(PlacesSortMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Spacer()
            Text("Henüz gidilen bir yer yok")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func row(index: Int, place: Place) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text("\(index)")
                .font(.headline)
                .foregroundStyle(AppColors.textSecondary)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 3) {
                Text(place.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(viewModel.dateText(for: place))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(viewModel.pinColor(for: place))
                Text(viewModel.averageText(for: place))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .glassCard(cornerRadius: 16, padding: 0)
    }
}
