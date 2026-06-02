//
//  AddPlaceSheet.swift
//  Loveyaniask
//
//  Yeni mekan ekleme: isim, konum, puan, fotoğraf, not, tarih.
//

import SwiftUI
import PhotosUI
import MapKit

struct AddPlaceSheet: View {
    let viewModel: PlacesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var note = ""
    @State private var rating = 0
    @State private var dateVisited = Date()
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingLocationPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Mekan") {
                    TextField("İsim (örn. Moda Sahili)", text: $name)
                }

                Section("Konum") {
                    Button {
                        showingLocationPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(AppColors.primary)
                            Text(coordinate == nil ? "Konum seç" : "Konum seçildi ✓")
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColors.textSecondary)
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
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerSheet(coordinate: $coordinate, name: $name)
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
        !name.trimmingCharacters(in: .whitespaces).isEmpty && coordinate != nil
    }

    private func save() {
        guard let coordinate else { return }
        viewModel.add(
            name: name.trimmingCharacters(in: .whitespaces),
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
