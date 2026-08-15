//
//  QuickNotesSection.swift
//  Loveyaniask
//
//  Ana sayfada (sayacın hemen altında) "Hızlı Not": aklınıza geleni hemen
//  ekleyip unutmamak için ortak, serbest not listesi. En yeni üstte.
//  Listenin ilk kartı hep yazma kartı — diğer not kartlarıyla aynı görünümde,
//  ayrı bir kutu/sheet değil, sadece 3 kart slotundan biri. Silmek için bir
//  nota uzun bas → Sil.
//

import SwiftUI

struct QuickNotesSection: View {
    @Bindable var viewModel: QuickNotesViewModel
    let kenCompanion: KenCompanion

    /// Bölümün alabileceği en fazla yükseklik. Bunu aşınca ana sayfa uzamaz;
    /// kartlar bu alanın içinde kendi kendine kaydırılır. Yazma kartı + 2 not
    /// kartı olmak üzere toplam ~3 kart sığacak şekilde ayarlı.
    private let maxHeight: CGFloat = 170

    /// İçindeki listenin gerçek (doğal) yüksekliği. Az kartta boşuna yer
    /// kaplamamak için yüksekliği min(içerik, tavan) olarak veriyoruz.
    @State private var contentHeight: CGFloat = 0

    @State private var draftText = ""
    @FocusState private var composeFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Hızlı Not")

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: AppSpacing.sm) {
                    composeCard

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
        .onChange(of: composeFocused) { _, focused in
            // Yazarken Ken araya girmesin diye dolaşmasını geçici durdur.
            if focused { kenCompanion.pause() } else { kenCompanion.resume() }
        }
    }

    private var composeCard: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField("Aklındaki...", text: $draftText, axis: .vertical)
                .focused($composeFocused)
                .lineLimit(1...3)
                .foregroundStyle(AppColors.textPrimary)

            Button("Ekle") {
                viewModel.add(draftText)
                draftText = ""
                composeFocused = false
                kenCompanion.celebrateEvent()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppColors.primary)
            .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 16, padding: AppSpacing.sm)
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
