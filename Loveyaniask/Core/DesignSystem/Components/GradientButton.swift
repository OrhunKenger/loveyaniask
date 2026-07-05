//
//  GradientButton.swift
//  Loveyaniask
//
//  Gül→mor aksan gradyan yardımcıları ve ana aksiyon butonu.
//

import SwiftUI

extension View {
    /// Gül→mor aksan gradyan arka plan (buton / pill için).
    func accentGradientBackground(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(AppColors.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// Ana aksiyon butonu — gül→mor gradyan, tam genişlik, yumuşak glow.
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title).font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .accentGradientBackground(cornerRadius: 16)
            .shadow(color: AppColors.primary.opacity(0.35), radius: 12, y: 6)
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled || isLoading)
    }
}
