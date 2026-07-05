//
//  PlacesView.swift
//  Loveyaniask
//
//  Tam ekran Mapbox haritası (koyu/gece tema); mekanlar ortalama puana göre renkli pin'lerle.
//  Pine basınca balon kart yaylanarak açılır.
//

import SwiftUI
import MapboxMaps
import CoreLocation

struct PlacesView: View {
    @State private var viewModel: PlacesViewModel
    /// Harita ancak bu sekme açıkken çizilsin (arka planda sürekli render = ısınma/kasma).
    let isActive: Bool

    init(viewModel: PlacesViewModel, isActive: Bool) {
        _viewModel = State(initialValue: viewModel)
        self.isActive = isActive
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(alignment: .bottomTrailing) {
            if isActive {
                Map(initialViewport: .camera(
                    center: CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0),
                    zoom: 4.2
                )) {
                    ForEvery(viewModel.visitedPlaces) { place in
                        MapViewAnnotation(coordinate: viewModel.coordinate(for: place)) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    viewModel.selectedPlace = place
                                }
                            } label: {
                                placePin(for: place)
                            }
                        }
                    }
                }
                .mapStyle(MapStyle(uri: StyleURI(rawValue: "mapbox://styles/orhunkenger/cmpzrdoxo003701r2c0e17cpo")!))
                .ignoresSafeArea(edges: .top)
            } else {
                AppColors.background
                    .ignoresSafeArea()
            }

            titlePill
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(AppSpacing.md)

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

    // Apple Haritalar tarzı: dümdüz dolu renkli nokta (halkasız).
    private func placePin(for place: Place) -> some View {
        Circle()
            .fill(viewModel.pinColor(for: place))
            .frame(width: 13, height: 13)
            .shadow(color: .black.opacity(0.3), radius: 1.5, y: 1)
    }

    private var titlePill: some View {
        Text("Gittiğimiz Yerler")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(AppColors.surface.opacity(0.9))
                    .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
    }

    // Harita üstünde yüzen + butonu (sabit, sağ alt).
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

