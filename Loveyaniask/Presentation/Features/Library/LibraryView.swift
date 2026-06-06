//
//  LibraryView.swift
//  Loveyaniask
//
//  Dijital Kütüphane: sinematik koyu vitrin. Tür sekmesi (Film/Dizi/Kitap) +
//  duruma göre poster rafları. Poster'a dokun → detay; + → ara & ekle.
//

import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel

    init(viewModel: LibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let statusOrder: [LibraryStatus] = [.inProgress, .want, .done]

    // Sinematik palet
    private let accent = Color(hex: "FF6FA5")
    private let textLight = Color.white
    private let textDim = Color.white.opacity(0.6)

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(alignment: .bottomTrailing) {
            cinematicBackground

            VStack(spacing: AppSpacing.md) {
                header
                kindPicker

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        if viewModel.isEmptyForSelectedKind {
                            emptyState
                        } else {
                            ForEach(statusOrder, id: \.self) { status in
                                let items = viewModel.items(status: status)
                                if !items.isEmpty {
                                    shelf(title: status.label(for: viewModel.selectedKind), items: items)
                                }
                            }
                        }
                    }
                    .padding(.vertical, AppSpacing.md)
                    .padding(.bottom, 90)
                }
            }

            addButton
                .padding(AppSpacing.lg)
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            LibraryAddSheet(viewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedItem) { item in
            LibraryDetailSheet(viewModel: viewModel, itemId: item.id)
        }
    }

    // MARK: - Arka plan

    private var cinematicBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "2A1B3D"), Color(hex: "140E22"), Color(hex: "08060F")],
                startPoint: .top,
                endPoint: .bottom
            )
            // Üstte yumuşak gül parıltısı
            RadialGradient(
                colors: [accent.opacity(0.30), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Başlık & tür

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text("Kütüphanemiz")
                    .font(.title2.bold())
                    .foregroundStyle(textLight)
                Spacer()
                Image(systemName: "popcorn.fill")
                    .foregroundStyle(accent)
            }
            Text("izlediğimiz, okuduğumuz her şey 🎬📖")
                .font(.caption)
                .foregroundStyle(textDim)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }

    private var kindPicker: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(LibraryKind.allCases) { kind in
                let selected = viewModel.selectedKind == kind
                Button {
                    withAnimation(.snappy(duration: 0.2)) { viewModel.selectedKind = kind }
                } label: {
                    Text("\(kind.emoji) \(kind.label)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selected ? .white : textLight.opacity(0.85))
                        .padding(.vertical, AppSpacing.sm)
                        .frame(maxWidth: .infinity)
                        .background {
                            if selected {
                                LinearGradient(colors: [accent, Color(hex: "B5479B")], startPoint: .leading, endPoint: .trailing)
                            } else {
                                Color.white.opacity(0.10)
                            }
                        }
                        .clipShape(Capsule())
                        .shadow(color: selected ? accent.opacity(0.4) : .clear, radius: 6, y: 3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Raf

    private func shelf(title: String, items: [LibraryItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(.headline)
                .foregroundStyle(textLight)
                .padding(.horizontal, AppSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    ForEach(items) { item in
                        posterCard(item)
                            .onTapGesture { viewModel.selectedItem = item }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, 4)
            }
        }
    }

    private func posterCard(_ item: LibraryItem) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            PosterImage(url: item.posterURL, kind: item.kind, width: 144)

            Text(item.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(textLight)
                .lineLimit(2)
                .frame(width: 144, alignment: .leading)

            if item.averageRating > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text(viewModel.ratingText(for: item))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(textDim)
                }
            }
        }
    }

    private var addButton: some View {
        Button {
            viewModel.showingAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(colors: [accent, Color(hex: "B5479B")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: accent.opacity(0.5), radius: 10, y: 6)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Text(viewModel.selectedKind.emoji)
                .font(.system(size: 56))
            Text("Henüz \(viewModel.selectedKind.label.lowercased()) yok")
                .font(.headline)
                .foregroundStyle(textLight)
            Text("Sağ alttaki + ile arayıp ekleyin")
                .font(.caption)
                .foregroundStyle(textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }
}

// MARK: - Poster görseli (yeniden kullanılır)

struct PosterImage: View {
    let url: String?
    let kind: LibraryKind
    var width: CGFloat = 144

    var body: some View {
        let height = width * 1.5
        let radius = max(16, width * 0.13)
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "3A2C52"), Color(hex: "211734")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    VStack(spacing: 4) {
                        Text(kind.emoji).font(.system(size: width * 0.34))
                        Text(kind.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                )

            if let url, let parsed = URL(string: url) {
                AsyncImage(url: parsed) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Color.clear
                    } else {
                        ProgressView().tint(.white)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 7)
    }
}
