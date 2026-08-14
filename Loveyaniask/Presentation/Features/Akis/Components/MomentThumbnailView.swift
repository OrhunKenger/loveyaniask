//
//  MomentThumbnailView.swift
//  Loveyaniask
//
//  Bir anın küçük resmi: fotoğrafsa direkt, videoysa ilk kareden çıkarılır.
//

import SwiftUI
import AVFoundation

struct MomentThumbnailView: View {
    let moment: Moment
    var viewModel: AkisViewModel

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Rectangle().fill(AppColors.glassFill)
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
            if moment.mediaType == .video {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
            }
        }
        .clipped()
        .task(id: moment.id) {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        await withCheckedContinuation { continuation in
            viewModel.loadMedia(for: moment) { url in
                guard let url else { continuation.resume(); return }
                if moment.mediaType == .photo {
                    image = UIImage(contentsOfFile: url.path)
                    continuation.resume()
                } else {
                    let asset = AVURLAsset(url: url)
                    let generator = AVAssetImageGenerator(asset: asset)
                    generator.appliesPreferredTrackTransform = true
                    // generateCGImagesAsynchronously'nin geri çağırması AVFoundation'ın
                    // kendi kuyruğunda çalışır (ana iş parçacığı değil) — @State'e
                    // yazmadan önce MainActor'a atlıyoruz.
                    generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: .zero)]) { _, cgImage, _, _, _ in
                        let result = cgImage.map { UIImage(cgImage: $0) }
                        Task { @MainActor in
                            image = result
                        }
                        continuation.resume()
                    }
                }
            }
        }
    }
}
