//
//  GlowBackground.swift
//  Loveyaniask
//
//  Uygulama geneli koyu arka plan: gece gradyanı + üstten statik gül parıltısı.
//  STATİK (bir kez render) → performans dostu. Ekranlar bunu taban olarak kullanır.
//

import SwiftUI

struct GlowBackground: View {
    /// Parıltının merkezi (varsayılan üst).
    var glowCenter: UnitPoint = .top
    /// Parıltı yoğunluğu.
    var intensity: Double = 0.20

    var body: some View {
        ZStack {
            AppColors.backgroundGradient
            RadialGradient(
                colors: [AppColors.primary.opacity(intensity), Color.clear],
                center: glowCenter,
                startRadius: 0,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}
