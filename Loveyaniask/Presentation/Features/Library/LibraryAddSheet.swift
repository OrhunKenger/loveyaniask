//
//  LibraryAddSheet.swift
//  Loveyaniask
//
//  Tür seç + ara (TMDB / Google Books) + dokun-ekle.
//

import SwiftUI

struct LibraryAddSheet: View {
    @Bindable var viewModel: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                // Tür seçimi
                Picker("Tür", selection: $viewModel.selectedKind) {
                    ForEach(LibraryKind.allCases) { kind in
                        Text("\(kind.emoji) \(kind.label)").tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppSpacing.md)
                .onChange(of: viewModel.selectedKind) { _, _ in
                    Task { await viewModel.runSearch() }
                }

                // Arama kutusu
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(AppColors.textSecondary)
                    TextField(searchPlaceholder, text: $viewModel.query)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                        .onSubmit { Task { await viewModel.runSearch() } }
                        .onChange(of: viewModel.query) { _, _ in
                            // Yazdıkça canlı ara (kısa gecikmeyle).
                            searchTask?.cancel()
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 400_000_000)
                                if !Task.isCancelled { await viewModel.runSearch() }
                            }
                        }
                    if !viewModel.query.isEmpty {
                        Button { viewModel.clearSearch() } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                .padding(AppSpacing.sm)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, AppSpacing.md)

                if viewModel.isSearching {
                    ProgressView().padding(.top, AppSpacing.lg)
                    Spacer()
                } else if viewModel.searchResults.isEmpty {
                    Spacer()
                    VStack(spacing: AppSpacing.sm) {
                        Text(viewModel.query.isEmpty ? "Aramak için bir şey yaz ✍️" : "Sonuç yok")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                        if let error = viewModel.lastError {
                            Text(error)
                                .font(.caption2)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(viewModel.searchResults) { result in
                                resultRow(result)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                }
            }
            .padding(.top, AppSpacing.sm)
            .background(AppColors.background)
            .navigationTitle("Kütüphaneye Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitti") { dismiss() }
                }
            }
        }
    }

    private var searchPlaceholder: String {
        switch viewModel.selectedKind {
        case .film: return "Film ara…"
        case .dizi: return "Dizi ara…"
        case .kitap: return "Kitap ara…"
        }
    }

    private func alreadyAdded(_ result: LibrarySearchResult) -> Bool {
        viewModel.items.contains { $0.title == result.title && $0.kind == viewModel.selectedKind }
    }

    private func resultRow(_ result: LibrarySearchResult) -> some View {
        HStack(spacing: AppSpacing.md) {
            PosterImage(url: result.posterURL, kind: viewModel.selectedKind, width: 56)

            VStack(alignment: .leading, spacing: 3) {
                Text(result.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                if let year = result.year {
                    Text(year)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                if !result.overview.isEmpty {
                    Text(result.overview)
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            let added = alreadyAdded(result)
            Button {
                viewModel.add(result)
            } label: {
                Image(systemName: added ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(added ? .green : AppColors.primary)
            }
            .disabled(added)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
