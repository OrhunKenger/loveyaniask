//
//  AkisView.swift
//  Loveyaniask
//
//  Akış sekmesi: günlere göre gruplanmış + karışık kronolojik akış,
//  ve Instagram-grid tarzı mozaik galeri arasında geçiş.
//

import SwiftUI

private enum AkisLayout {
    case feed
    case grid
}

struct AkisView: View {
    var viewModel: AkisViewModel

    @State private var layout: AkisLayout = .feed
    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    private static let dayHeaderFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM EEEE"
        return f
    }()

    var body: some View {
        ZStack {
            GlowBackground()

            VStack(spacing: 0) {
                header

                if viewModel.moments.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        switch layout {
                        case .feed: feedContent
                        case .grid: gridContent
                        }
                    }
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    MomentCaptureButton(viewModel: viewModel)
                        .padding(.trailing, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        .sheet(item: Binding(
            get: { viewModel.selectedMoment },
            set: { viewModel.selectedMoment = $0 }
        )) { moment in
            MomentDetailView(moment: moment, viewModel: viewModel) {
                viewModel.selectedMoment = nil
            }
        }
        .alert(
            "Bir şeyler ters gitti",
            isPresented: Binding(
                get: { viewModel.uploadError != nil },
                set: { if !$0 { viewModel.uploadError = nil } }
            )
        ) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(viewModel.uploadError ?? "")
        }
    }

    private var header: some View {
        HStack {
            Text("Akış")
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button {
                withAnimation(.snappy) { layout = layout == .feed ? .grid : .feed }
            } label: {
                Image(systemName: layout == .feed ? "square.grid.3x3" : "rectangle.stack")
                    .font(.title3)
                    .foregroundStyle(AppColors.primary)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.sm)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Spacer()
            Image(systemName: "camera.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.textSecondary)
            Text("Henüz bir an paylaşılmadı")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var feedContent: some View {
        LazyVStack(alignment: .leading, spacing: AppSpacing.lg) {
            ForEach(viewModel.daySections) { section in
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(Self.dayHeaderFormatter.string(from: section.date))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.lg)

                    ForEach(section.moments) { moment in
                        Button {
                            viewModel.selectedMoment = moment
                        } label: {
                            MomentThumbnailView(moment: moment, viewModel: viewModel)
                                .aspectRatio(4.0 / 5.0, contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(alignment: .bottomLeading) {
                                    Text(viewModel.authorLabel(moment))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Capsule().fill(.black.opacity(0.35)))
                                        .padding(10)
                                }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
        .padding(.bottom, 100)
    }

    private var gridContent: some View {
        LazyVGrid(columns: gridColumns, spacing: 2) {
            ForEach(viewModel.moments) { moment in
                Button {
                    viewModel.selectedMoment = moment
                } label: {
                    MomentThumbnailView(moment: moment, viewModel: viewModel)
                        .aspectRatio(1, contentMode: .fill)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 100)
    }
}
