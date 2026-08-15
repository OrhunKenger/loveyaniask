//
//  GlassCard.swift
//  Loveyaniask
//
//  Koyu, yarı saydam "cam" kart görünümü. STATİK (canlı blur YOK → ucuz/performanslı):
//  koyu yüzey + üstten hafif ışık sheen'i + hairline kenar.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 22
    var padding: CGFloat? = AppSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            // Zemin ve üstteki ışık sheen'i TEK gradyanda birleştirildi. Eskiden
            // düz dolgunun üstüne ikinci bir gradyan katmanı biniyordu; her kart
            // fazladan bir katman demekti ve uygulamada 18 çağrı yeri var
            // (bir kısmı liste satırı, yani ekranda onlarca kez).
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "29243E"), AppColors.surface],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.glassStroke, lineWidth: 1)
            )
    }
}

extension View {
    /// Koyu cam kart görünümü uygular.
    func glassCard(cornerRadius: CGFloat = 22, padding: CGFloat? = AppSpacing.md) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
