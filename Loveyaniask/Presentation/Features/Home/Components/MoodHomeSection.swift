//
//  MoodHomeSection.swift
//  Loveyaniask
//
//  Ana sayfada bugünün ruh hali kartı: emoji + isimli çiplere TEK DOKUNUŞLA
//  kendi halini seç, partnerinkini gör. Çipler sarmalı ızgarada dizilir;
//  hepsi tek bakışta görünür, ismi okumak için ekstra menü/sheet gerekmez.
//  Takvim ikonuna dokununca tam aylık takvim açılır.
//

import SwiftUI

struct MoodHomeSection: View {
    @Bindable var viewModel: MoodViewModel
    @State private var showingCalendar = false

    /// Çip ızgarasının kendi içinde kaydırıldığı en fazla yükseklik (yaklaşık 4 satır).
    private let maxGridHeight: CGFloat = 170
    /// Izgaranın doğal yüksekliği (az duyguda boşuna yer kaplamamak için).
    @State private var gridHeight: CGFloat = 0

    private var today: Date { Date() }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Bugün nasıl hissediyorsun?")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button {
                    showingCalendar = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }

            // Emoji + isimli çipler — sarmalı ızgara, kendi içinde kaydırılır
            ScrollView(.vertical, showsIndicators: true) {
                FlowLayout(spacing: AppSpacing.sm, lineSpacing: AppSpacing.sm) {
                    ForEach(Mood.displayOrder) { mood in
                        let selected = viewModel.mood(for: today, partner: .me) == mood
                        moodChip(mood, selected: selected, tint: Self.valenceColor(for: mood))
                            .onTapGesture {
                                withAnimation(.snappy(duration: 0.2)) {
                                    viewModel.setMood(date: today, partner: .me, mood: mood)
                                }
                            }
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: MoodGridHeightKey.self, value: proxy.size.height)
                    }
                )
            }
            .frame(height: min(gridHeight, maxGridHeight))
            .scrollDisabled(gridHeight <= maxGridHeight)
            .onPreferenceChange(MoodGridHeightKey.self) { gridHeight = $0 }

            // Partnerin bugünü
            HStack(spacing: 8) {
                Text("\(viewModel.title(for: .partner)):")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)
                if let mood = viewModel.mood(for: today, partner: .partner) {
                    HStack(spacing: 4) {
                        EmojiIcon(emoji: mood.emoji, size: 18)
                        Text(mood.label)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                } else {
                    Text("henüz paylaşmadı 🫥")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }
        }
        .glassCard(cornerRadius: 20, padding: AppSpacing.lg)
        .sheet(isPresented: $showingCalendar) {
            NavigationStack {
                MoodView(viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Kapat") { showingCalendar = false }
                        }
                    }
            }
            .presentationDetents([.large, .medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func moodChip(_ mood: Mood, selected: Bool, tint: Color) -> some View {
        HStack(spacing: 5) {
            EmojiIcon(emoji: mood.emoji, size: 17)
            Text(mood.label)
                .font(.subheadline.weight(selected ? .semibold : .regular))
                .foregroundStyle(selected ? AppColors.textPrimary : AppColors.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(tint.opacity(selected ? 0.32 : 0.14))
        )
        .overlay(
            Capsule().stroke(tint.opacity(selected ? 1 : 0.4), lineWidth: selected ? 2 : 1)
        )
        .contentShape(Capsule())
    }

    /// Duyguyu, akış sırasındaki konumuna göre sıcaktan (mutlu) soğuğa (zor)
    /// bir renk skalasında konumlandırır — 47 seçenek arasında göz, tek düz
    /// bulut yerine bir "sıcaklık akışı" takip ederek tarar.
    private static func valenceColor(for mood: Mood) -> Color {
        let order = Mood.displayOrder
        guard let index = order.firstIndex(of: mood), order.count > 1 else { return AppColors.primary }
        let t = Double(index) / Double(order.count - 1)
        let warm = (r: 255.0, g: 111.0, b: 165.0)   // AppColors.primary — gül
        let cool = (r: 127.0, g: 160.0, b: 216.0)   // soğuk mavi
        let r = warm.r + (cool.r - warm.r) * t
        let g = warm.g + (cool.g - warm.g) * t
        let b = warm.b + (cool.b - warm.b) * t
        return Color(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: 1)
    }
}

/// Mood çip ızgarasının doğal yüksekliğini ölçmek için.
private struct MoodGridHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Basit sarmalı (flow) yerleşim: çipler satıra sığmayınca alt satıra sarar.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubviews.Element]] = [[]]
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = rowWidth == 0 ? size.width : rowWidth + spacing + size.width
            if needed > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + lineSpacing
                rows.append([subview])
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rows[rows.count - 1].append(subview)
                rowWidth = needed
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
