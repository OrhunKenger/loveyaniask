//
//  QuickNotesSection.swift
//  Loveyaniask
//
//  Ana sayfada (sayacın hemen altında) "Hızlı Not": aklınıza geleni hemen
//  ekleyip unutmamak için ortak, serbest not listesi. En yeni üstte.
//  Silmek için bir nota uzun bas → Sil.
//

import SwiftUI

struct QuickNotesSection: View {
    @Bindable var viewModel: QuickNotesViewModel

    /// Bölümün alabileceği en fazla yükseklik. Bunu aşınca ana sayfa uzamaz;
    /// notlar bu alanın içinde kendi kendine kaydırılır (yeni üstte, eski aşağıda).
    private let maxHeight: CGFloat = 280

    /// İçindeki not listesinin gerçek (doğal) yüksekliği. Az notta boşuna yer
    /// kaplamamak için yüksekliği min(içerik, tavan) olarak veriyoruz.
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Hızlı Not") { viewModel.showingAdd = true }

            if viewModel.notes.isEmpty {
                Text("Aklınıza geleni hemen ekleyin — + ile not bırakın (unutmayın diye)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.notes) { note in
                            noteRow(note)
                        }
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: QuickNotesHeightKey.self, value: proxy.size.height)
                        }
                    )
                }
                .frame(height: min(contentHeight, maxHeight))
                .scrollDisabled(contentHeight <= maxHeight)
                .onPreferenceChange(QuickNotesHeightKey.self) { contentHeight = $0 }
            }
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            AddQuickNoteSheet(viewModel: viewModel)
        }
    }

    private func noteRow(_ note: QuickNote) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(AppColors.primary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(note.text)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(viewModel.authorName(note)) · \(viewModel.dateText(note))")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 16, padding: AppSpacing.sm)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(note)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}

/// Hızlı notlar listesinin doğal yüksekliğini ölçmek için kullanılır.
private struct QuickNotesHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
