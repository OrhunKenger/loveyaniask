//
//  EditProfileSheet.swift
//  Loveyaniask
//
//  Kendi profilini düzenle: fotoğraf + "hakkımda". Kaydedince senkron olur.
//

import SwiftUI
import PhotosUI

struct EditProfileSheet: View {
    let viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var bio = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var photoChanged = false
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            ZStack {
                GlowBackground()

                VStack(spacing: AppSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppColors.accentGradient)
                            .frame(width: 124, height: 124)
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 116, height: 116)
                                .clipShape(Circle())
                        } else {
                            Text(viewModel.currentUser.initials)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 16, y: 6)

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(image == nil ? "Fotoğraf seç" : "Fotoğrafı değiştir", systemImage: "photo")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.primary)
                    }
                    .onChange(of: pickerItem) { _, item in
                        guard let item else { return }
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let ui = UIImage(data: data) {
                                image = ui
                                photoChanged = true
                            }
                        }
                    }

                    TextField("Hakkımda…", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(AppSpacing.md)
                        .background(AppColors.glassFill)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppColors.glassStroke, lineWidth: 1)
                        )

                    PrimaryButton(title: "Kaydet") {
                        viewModel.saveMyProfile(bio: bio, image: photoChanged ? image : nil)
                        dismiss()
                    }

                    Spacer()
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("Profilini Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
            }
            .onAppear {
                guard !loaded else { return }
                loaded = true
                bio = viewModel.bio(for: viewModel.currentUser)
                image = viewModel.image(for: viewModel.currentUser)
            }
        }
    }
}
