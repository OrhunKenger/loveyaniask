//
//  MemoryJarSection.swift
//  Loveyaniask
//
//  Ana sayfadaki SADE kavanoz: kart yok, başlık yok. Boşlukta küçük bir kavanoz,
//  üstünde not sayısı + kalan gün / durum. Üstüne dokununca duruma göre açılır:
//  toplarken not ekleme, hazırken onay, açıkken okuma.
//

import SwiftUI

struct MemoryJarSection: View {
    @Bindable var viewModel: JarViewModel

    var body: some View {
        VStack(spacing: 6) {
            Text(statusText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)

            MemoryJarView(count: viewModel.count, isReady: viewModel.isReady, scale: 0.6)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { primaryTap() }
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

    private func primaryTap() {
        switch viewModel.state {
        case .collecting: viewModel.showingAdd = true
        case .ready:      viewModel.showingApprove = true
        case .opened:     viewModel.showingReveal = true
        }
    }

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
