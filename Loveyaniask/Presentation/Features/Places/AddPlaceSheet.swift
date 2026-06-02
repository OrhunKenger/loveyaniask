//
//  AddPlaceSheet.swift
//  Loveyaniask
//
//  Yeni mekan ekleme: ad yazınca canlı arama (dropdown), seçilince konum gelir.
//

import SwiftUI
import PhotosUI
import MapKit

struct AddPlaceSheet: View {
    let viewModel: PlacesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var search = PlaceSearchCompleter()
    @State private var selectedTitle: String?
    @State private var coordinate: CLLocationCoordinate2D?

    @State private var note = ""
    @State private var rating = 0
    @State private var dateVisited = Date()
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        @Bindable var search = search

        NavigationStack {
            Form {
                Section("Mekan") {
                    if let selectedTitle {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(AppColors.primary)
                            Text(selectedTitle)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Button {
                                clearSelection()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    } else {
                        TextField("Mekan ara (örn. Moda Sahili)", text: $search.query)

                        ForEach(search.results, id: \.self) { result in
                            Button {
                                select(result)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .foregroundStyle(AppColors.textPrimary)
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Senin puanın") {
                    starsPicker
                }

                Section("Fotoğraf") {
                    photoPicker
                }

                Section("Not") {
                    TextField("Anı / yorum", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Tarih") {
                    DatePicker("Gidilen tarih", selection: $dateVisited, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
            }
            .navigationTitle("Mekan Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var starsPicker: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(star <= rating ? AppColors.primary : AppColors.textSecondary)
                    .onTapGesture { rating = star }
            }
        }
    }

    private var photoPicker: some View {
        VStack(spacing: AppSpacing.sm) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label(imageData == nil ? "Fotoğraf ekle" : "Fotoğrafı değiştir", systemImage: "photo")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.primary)
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        selectedTitle != nil && coordinate != nil
    }

    private func select(_ result: MKLocalSearchCompletion) {
        let title = result.title
        search.resolve(result) { coord in
            coordinate = coord
            selectedTitle = title
        }
    }

    private func clearSelection() {
        selectedTitle = nil
        coordinate = nil
        search.clear()
    }

    private func save() {
        guard let selectedTitle, let coordinate else { return }
        viewModel.add(
            name: selectedTitle,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            rating: rating,
            note: note,
            dateVisited: dateVisited,
            imageData: imageData
        )
        dismiss()
    }
}
