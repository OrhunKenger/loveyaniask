//
//  MomentCaptureButton.swift
//  Loveyaniask
//
//  Akış'a yeni an ekleme: kameradan çek veya galeriden seç.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct MomentCaptureButton: View {
    var viewModel: AkisViewModel

    @State private var showingSourceDialog = false
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        Button {
            showingSourceDialog = true
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.accentGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: AppColors.primary.opacity(0.5), radius: 12, y: 4)
                if viewModel.isUploading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .disabled(viewModel.isUploading)
        .confirmationDialog("Bir an ekle", isPresented: $showingSourceDialog, titleVisibility: .visible) {
            Button("Kameradan çek") { showingCamera = true }
            Button("Galeriden seç") { showingGallery = true }
            Button("Vazgeç", role: .cancel) {}
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraCaptureView(
                onCapture: { mediaType, url in
                    showingCamera = false
                    viewModel.upload(mediaType: mediaType, fileURL: url)
                },
                onCancel: { showingCamera = false }
            )
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showingGallery, selection: $pickerItem, matching: .any(of: [.images, .videos]))
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            loadPickedItem(newItem)
            pickerItem = nil
        }
    }

    private func loadPickedItem(_ item: PhotosPickerItem) {
        let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) }
        if isVideo {
            Task {
                if let video = try? await item.loadTransferable(type: TransferableVideo.self) {
                    viewModel.upload(mediaType: .video, fileURL: video.url)
                }
            }
        } else {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + ".jpg")
                    try? data.write(to: tempURL)
                    viewModel.upload(mediaType: .photo, fileURL: tempURL)
                }
            }
        }
    }
}
