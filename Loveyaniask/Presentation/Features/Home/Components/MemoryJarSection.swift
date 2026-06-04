//
//  MemoryJarSection.swift
//  Loveyaniask
//
//  Ana sayfada YÜZEN, sürüklenebilir kavanoz (AssistiveTouch gibi).
//  Tut-sürükle ile istediğin yere taşırsın, bıraktığın yer hatırlanır.
//  Kısa dokunuş = duruma göre aç (not ekle / onayla / oku).
//

import SwiftUI

struct MemoryJarSection: View {
    @Bindable var viewModel: JarViewModel

    @State private var center: CGPoint? = nil
    @GestureState private var drag: CGSize = .zero

    private let posXKey = "jarPosX"
    private let posYKey = "jarPosY"

    var body: some View {
        GeometryReader { geo in
            jarContent
                .scaleEffect(drag == .zero ? 1 : 1.08)
                .position(center ?? defaultCenter(geo))
                .offset(drag)
                .gesture(dragGesture(geo))
                .onAppear {
                    if center == nil { center = loadCenter(geo) }
                }
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            AddJarNoteSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingReveal) {
            JarRevealSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingApprove) {
            JarApproveSheet(viewModel: viewModel)
        }
    }

    // MARK: - Kavanoz + durum

    private var jarContent: some View {
        VStack(spacing: 6) {
            Text(statusText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 3)
                .background(AppColors.surface.opacity(0.85))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 3, y: 1)

            MemoryJarView(count: viewModel.count, isReady: viewModel.isReady, scale: 0.6)
        }
        .contentShape(Rectangle())
        .shadow(color: .black.opacity(drag == .zero ? 0 : 0.2), radius: 12, y: 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: drag)
    }

    // MARK: - Sürükleme + dokunma

    private func dragGesture(_ geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($drag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let distance = hypot(value.translation.width, value.translation.height)
                if distance < 10 {
                    primaryTap()   // kısa dokunuş
                } else {
                    var c = center ?? defaultCenter(geo)
                    c.x += value.translation.width
                    c.y += value.translation.height
                    c = clamp(c, in: geo.size)
                    center = c
                    saveCenter(c)
                }
            }
    }

    private func primaryTap() {
        switch viewModel.state {
        case .collecting: viewModel.showingAdd = true
        case .ready:      viewModel.showingApprove = true
        case .opened:     viewModel.showingReveal = true
        }
    }

    // MARK: - Konum yardımcıları

    private func defaultCenter(_ geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.72)
    }

    private func clamp(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let marginX: CGFloat = 70
        let marginY: CGFloat = 90
        return CGPoint(
            x: min(max(point.x, marginX), size.width - marginX),
            y: min(max(point.y, marginY), size.height - marginY)
        )
    }

    private func loadCenter(_ geo: GeometryProxy) -> CGPoint {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: posXKey) != nil,
              defaults.object(forKey: posYKey) != nil else {
            return defaultCenter(geo)
        }
        let p = CGPoint(x: defaults.double(forKey: posXKey),
                        y: defaults.double(forKey: posYKey))
        return clamp(p, in: geo.size)
    }

    private func saveCenter(_ point: CGPoint) {
        UserDefaults.standard.set(Double(point.x), forKey: posXKey)
        UserDefaults.standard.set(Double(point.y), forKey: posYKey)
    }

    // MARK: - Durum metni

    private var statusText: String {
        switch viewModel.state {
        case .collecting:
            let d = viewModel.daysLeft
            return d == 0
                ? "\(viewModel.count) not · bugün açılabilir"
                : "\(viewModel.count) not · \(d) gün kaldı"
        case .ready:
            return "Açılmaya hazır 🎉 · dokun"
        case .opened:
            return "Açıldı 💖 · oku"
        }
    }

    private var statusColor: Color {
        viewModel.state == .collecting ? AppColors.textSecondary : AppColors.primary
    }
}
