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

    @State private var addCenter: CGPoint? = nil
    @GestureState private var addDrag: CGSize = .zero

    private let posXKey = "placeAddPosX"
    private let posYKey = "placeAddPosY"

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
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.pinColor(for: place))
                                .background(Circle().fill(.white).padding(3))
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .mapStyle(.dark)
            .ignoresSafeArea(edges: .top)

            titlePill
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(AppSpacing.md)

            floatingAddButton
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
        Text("Gittiğimiz Yerler")
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }

    // Harita üstünde yüzen, sürüklenebilir + butonu (kavanoz gibi).
    private var floatingAddButton: some View {
        GeometryReader { geo in
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(AppColors.primary)
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: addDrag == .zero ? 10 : 16, y: 6)
                .scaleEffect(addDrag == .zero ? 1 : 1.1)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: addDrag)
                .position(addCenter ?? defaultAddCenter(geo))
                .offset(addDrag)
                .gesture(addDragGesture(geo))
                .onAppear { if addCenter == nil { addCenter = loadAddCenter(geo) } }
        }
    }

    private func addDragGesture(_ geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($addDrag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let distance = hypot(value.translation.width, value.translation.height)
                if distance < 10 {
                    viewModel.showingAdd = true
                } else {
                    var c = addCenter ?? defaultAddCenter(geo)
                    c.x += value.translation.width
                    c.y += value.translation.height
                    c = clampAdd(c, in: geo.size)
                    addCenter = c
                    saveAddCenter(c)
                }
            }
    }

    private func defaultAddCenter(_ geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width - 50, y: geo.size.height - 50)
    }

    private func clampAdd(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let margin: CGFloat = 40
        return CGPoint(
            x: min(max(point.x, margin), size.width - margin),
            y: min(max(point.y, margin), size.height - margin)
        )
    }

    private func loadAddCenter(_ geo: GeometryProxy) -> CGPoint {
        let d = UserDefaults.standard
        guard d.object(forKey: posXKey) != nil, d.object(forKey: posYKey) != nil else {
            return defaultAddCenter(geo)
        }
        return clampAdd(CGPoint(x: d.double(forKey: posXKey), y: d.double(forKey: posYKey)), in: geo.size)
    }

    private func saveAddCenter(_ point: CGPoint) {
        UserDefaults.standard.set(Double(point.x), forKey: posXKey)
        UserDefaults.standard.set(Double(point.y), forKey: posYKey)
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
