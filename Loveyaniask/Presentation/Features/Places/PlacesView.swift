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
                            heartPin(for: place)
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

    // İnce & tatlı kalp pin: küçük beyaz rozet + puana göre renkli kalp, minik kuyruklu.
    private func heartPin(for place: Place) -> some View {
        VStack(spacing: -2) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.18), radius: 2.5, y: 1.5)
                Image(systemName: "heart.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(viewModel.pinColor(for: place))
            }
            PinTail()
                .fill(.white)
                .frame(width: 9, height: 6)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
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

/// Pin'in altındaki küçük aşağı bakan kuyruk (üçgen).
private struct PinTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
