//
//  MomentDetailView.swift
//  Loveyaniask
//
//  Bir anın tam ekran görünümü: fotoğraf/video, kim-ne-zaman, silme,
//  ve "tekrar göster" tepkisi.
//

import SwiftUI
import AVKit

struct MomentDetailView: View {
    let moment: Moment
    var viewModel: AkisViewModel
    var onDismiss: () -> Void

    @State private var localURL: URL?
    @State private var showingResurfaceSheet = false
    @State private var showingDeleteConfirm = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy, HH:mm"
        return f
    }()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let localURL {
                if moment.mediaType == .photo, let uiImage = UIImage(contentsOfFile: localURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else if moment.mediaType == .video {
                    VideoPlayer(player: AVPlayer(url: localURL))
                }
            } else {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                header
                Spacer()
                if let comment = moment.kenComment {
                    kenCommentCard(comment)
                }
                footer
            }
        }
        .task {
            viewModel.loadMedia(for: moment) { url in
                localURL = url
            }
        }
        .sheet(isPresented: $showingResurfaceSheet) {
            ResurfacePickerSheet(
                moment: moment,
                onConfirm: { date in
                    viewModel.setResurface(moment, date: date)
                    showingResurfaceSheet = false
                },
                onCancel: { showingResurfaceSheet = false }
            )
        }
        .confirmationDialog("Bu an silinsin mi?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Sil", role: .destructive) {
                viewModel.delete(moment)
                onDismiss()
            }
            Button("Vazgeç", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.authorLabel(moment))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(Self.dateFormatter.string(from: moment.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .black.opacity(0.4))
            }
        }
        .padding()
        .padding(.top, AppSpacing.md)
    }

    private func kenCommentCard(_ text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text("🐾")
                .font(.subheadline)

            VStack(alignment: .leading, spacing: 2) {
                Text("Ken bunu hatırlattı")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppColors.primary)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppColors.glassStroke, lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.bottom, AppSpacing.sm)
    }

    private var footer: some View {
        HStack(spacing: AppSpacing.lg) {
            Button {
                showingResurfaceSheet = true
            } label: {
                Label(
                    moment.resurfaceAt == nil ? "Bunu tekrar göster" : "Tekrar gösterilecek",
                    systemImage: moment.resurfaceAt == nil ? "clock.arrow.circlepath" : "checkmark.circle.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Capsule().fill(.white.opacity(0.18)))
            }

            if viewModel.canDelete(moment) {
                Button {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(AppSpacing.sm)
                        .background(Circle().fill(.white.opacity(0.18)))
                }
            }

            Spacer()
        }
        .padding()
        .padding(.bottom, AppSpacing.lg)
    }
}
