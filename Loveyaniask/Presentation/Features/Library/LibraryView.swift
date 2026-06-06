//
//  LibraryView.swift
//  Loveyaniask
//
//  Dijital Kütüphane: tür sekmesi (Film/Dizi/Kitap) + duruma göre poster rafları.
//  Poster'a dokun → detay; sağ alttaki + → ara & ekle.
//

import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel

    init(viewModel: LibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let statusOrder: [LibraryStatus] = [.inProgress, .want, .done]

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [AppColors.primary.opacity(0.10), AppColors.background],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

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
                    .padding(.bottom, 80)
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

    // MARK: - Başlık & tür

    private var header: some View {
        HStack {
            Text("Kütüphanemiz")
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Image(systemName: "books.vertical.fill")
                .foregroundStyle(AppColors.primary)
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
                        .foregroundStyle(selected ? .white : AppColors.textPrimary)
                        .padding(.vertical, AppSpacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(selected ? AppColors.primary : AppColors.surface)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(selected ? 0.15 : 0.04), radius: 5, y: 2)
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
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    ForEach(items) { item in
                        posterCard(item)
                            .onTapGesture { viewModel.selectedItem = item }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }

    private func posterCard(_ item: LibraryItem) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            PosterImage(url: item.posterURL, kind: item.kind, width: 144)

            Text(item.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2)
                .frame(width: 144, alignment: .leading)

            if item.averageRating > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text(viewModel.ratingText(for: item))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
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
                .background(AppColors.primary)
                .clipShape(Circle())
                .shadow(color: AppColors.primary.opacity(0.4), radius: 10, y: 6)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Text(viewModel.selectedKind.emoji)
                .font(.system(size: 54))
            Text("Henüz \(viewModel.selectedKind.label.lowercased()) yok")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text("Sağ alttaki + ile arayıp ekleyin")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
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
                        colors: [AppColors.surface, AppColors.primary.opacity(0.12)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .overlay(
                    VStack(spacing: 4) {
                        Text(kind.emoji).font(.system(size: width * 0.34))
                        Text(kind.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .opacity(0.6)
                )

            if let url, let parsed = URL(string: url) {
                AsyncImage(url: parsed) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Color.clear
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 9, x: 0, y: 6)
    }
}
