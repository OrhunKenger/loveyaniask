//
//  LaunchContainer.swift
//  Loveyaniask
//
//  Açılış animasyonu: launcher ikonu (ikinizin fotoğrafı) belirip BÜYÜYEREK
//  uygulamayı "açar" (zoom-through) — sistemin ikon-zoom'unu sürdürür hissi.
//  Tüm uygulamayı (AuthGateView) sarmalar; soğuk açılışta bir kez oynar.
//

import SwiftUI

struct LaunchContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// Açılış bitti, overlay kaldırıldı mı?
    @State private var revealed = false
    /// Fotoğraf-ikonun büyüme ölçeği (girişte 0.92 → 1, sonra büyüyerek ekranı yutar).
    @State private var iconScale: CGFloat = 0.92
    @State private var overlayOpacity: Double = 1
    /// Uygulama içeriği hafif yakınlaşıp (1.06) yerine otursun (derinlik hissi).
    @State private var contentScale: CGFloat = 1.06

    /// Launcher ikonuyla aynı kare fotoğraf (ikon boyutuna yakın).
    private let iconSide: CGFloat = 132

    var body: some View {
        ZStack {
            content
                .scaleEffect(revealed ? 1 : contentScale)

            if !revealed {
                launchScreen
                    .opacity(overlayOpacity)
            }
        }
        .task { await playOpening() }
    }

    private var launchScreen: some View {
        ZStack {
            AppColors.backgroundGradient

            Image("LaunchLogo")
                .resizable()
                .scaledToFill()
                .frame(width: iconSide, height: iconSide)
                .clipShape(RoundedRectangle(cornerRadius: iconSide * 0.225, style: .continuous))
                .scaleEffect(iconScale)
        }
        .ignoresSafeArea()
    }

    private func playOpening() async {
        // 1) Fotoğraf-ikon yumuşakça belirir (launcher'dakiyle aynı).
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            iconScale = 1
        }
        // 2) Kısa bir nefes.
        try? await Task.sleep(for: .seconds(0.7))
        // 3) Fotoğraf büyüyerek uygulamayı "açar": ekranı yutar, overlay solar,
        //    içerik yerine oturur.
        withAnimation(.easeIn(duration: 0.55)) {
            iconScale = 13
            overlayOpacity = 0
            contentScale = 1
        }
        try? await Task.sleep(for: .seconds(0.55))
        revealed = true
    }
}
