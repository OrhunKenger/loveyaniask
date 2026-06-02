//
//  PlacesView.swift
//  Loveyaniask
//
//  Tam ekran kaydırılabilir harita; mekanlar ortalama puana göre renkli pin'lerle.
//  Pine basınca balon kart yaylanarak açılır.
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

        ZStack(alignment: .bottomTrailing) {
            Map(initialPosition: .region(viewModel.initialRegion)) {
                ForEach(viewModel.places) { place in
                    Annotation(place.name, coordinate: viewModel.coordinate(for: place)) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.selectedPlace = place
                            }
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.pinColor(for: place))
                                .background(Circle().fill(.white).padding(3))
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            titlePill
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(AppSpacing.md)

            if viewModel.places.isEmpty {
                emptyHint
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            addButton
                .padding(AppSpacing.lg)
        }
        .overlay {
            if let place = viewModel.selectedPlace {
                balloonOverlay(place)
            }
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            AddPlaceSheet(viewModel: viewModel)
        }
    }

    private var titlePill: some View {
        Text("Gittiğimiz Mekanlar")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }

    private var addButton: some View {
        Button {
            viewModel.showingAdd = true
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

    private var emptyHint: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.primary)
            Text("Henüz mekan yok")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("Sağ alttaki + ile ilk yerinizi ekleyin")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func balloonOverlay(_ place: Place) -> some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { dismissBalloon() }

            PlaceDetailBalloon(viewModel: viewModel, placeId: place.id, onClose: dismissBalloon)
                .padding(AppSpacing.lg)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }

    private func dismissBalloon() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            viewModel.selectedPlace = nil
        }
    }
}
