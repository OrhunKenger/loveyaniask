//
//  LocationPickerSheet.swift
//  Loveyaniask
//
//  Konum seçme: arama (MKLocalSearch) veya haritaya dokunarak pin koyma.
//

import SwiftUI
import MapKit

struct LocationPickerSheet: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var name: String

    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var picked: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.0, longitude: 35.0),
            span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
        )
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: AppSpacing.sm) {
                    TextField("Mekan ara (örn. Kadıköy Moda)", text: $query)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(search)
                    Button("Ara", action: search)
                        .buttonStyle(.borderedProminent)
                }
                .padding(AppSpacing.md)

                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let picked {
                            Marker("Seçilen", coordinate: picked)
                                .tint(AppColors.primary)
                        }
                    }
                    .onTapGesture { point in
                        if let coord = proxy.convert(point, from: .local) {
                            picked = coord
                        }
                    }
                }

                Text("İpucu: arama yap ya da haritaya dokunarak pin koy")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(AppSpacing.sm)
            }
            .navigationTitle("Konum Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Seç") {
                        coordinate = picked
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(picked == nil)
                }
            }
            .onAppear { picked = coordinate }
        }
    }

    private func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        MKLocalSearch(request: request).start { response, _ in
            guard let item = response?.mapItems.first else { return }
            let coord = item.placemark.coordinate
            picked = coord
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                name = item.name ?? query
            }
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }
}
