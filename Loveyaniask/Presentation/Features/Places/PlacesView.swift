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

    init(viewModel: PlacesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(alignment: .bottomTrailing) {
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

    // Apple Haritalar tarzı zarif nokta + altında mekan adı (yakın yerler ayrışsın diye).
    private func placePin(for place: Place) -> some View {
        VStack(spacing: 3) {
            Circle()
                .fill(viewModel.pinColor(for: place))
                .frame(width: 11, height: 11)
                .overlay(Circle().stroke(.white, lineWidth: 1.8))
                .shadow(color: .black.opacity(0.35), radius: 1.5, y: 1)

            Text(place.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: 100)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(.black.opacity(0.55)))
        }
        .fixedSize()
    }

    private var titlePill: some View {
        Text("Gittiğimiz Yerler")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
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

