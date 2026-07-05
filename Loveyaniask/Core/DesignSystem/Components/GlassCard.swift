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
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.07), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
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
