//
//  MemoryJarView.swift
//  Loveyaniask
//
//  Gerçeksi cam kavanoz: not eklendikçe içine kâğıtlar dolar.
//  Üstünde not sayısı rozeti; açılmaya hazırken altında sıcak bir parıltı.
//

import SwiftUI

struct MemoryJarView: View {
    let count: Int
    var isReady: Bool = false

    @State private var glow = false

    private var displayed: Int { min(count, 24) }

    private var glassFill: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.55), Color(hex: "CBD8EE").opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            countBadge

            jar
                .background(readyGlow)
                .onAppear {
                    guard isReady else { return }
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        glow = true
                    }
                }
        }
    }

    // MARK: - Sayı rozeti

    private var countBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "envelope.fill")
                .font(.caption2)
            Text("\(count) not")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: AppColors.primary.opacity(0.35), radius: 5, y: 3)
    }

    // MARK: - Kavanoz

    private var jar: some View {
        VStack(spacing: -5) {
            // Kapak
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 104, height: 26)
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
                    .frame(width: 104, height: 26)
            }
            .zIndex(2)

            // Vida halkası
            RoundedRectangle(cornerRadius: 3)
                .fill(glassFill)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(.white.opacity(0.6), lineWidth: 1))
                .frame(width: 92, height: 12)
                .zIndex(1)

            // Gövde
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(glassFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(.white.opacity(0.7), lineWidth: 1.5)
                    )

                // Kâğıtlar
                ZStack(alignment: .bottom) {
                    ForEach(0..<displayed, id: \.self) { index in
                        paper(index: index)
                    }
                }
                .padding(.bottom, 18)
                .padding(.horizontal, 14)

                // Parlama (cam efekti)
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)

                // Sol kenar ışık çizgisi
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .trim(from: 0.55, to: 0.72)
                    .stroke(.white.opacity(0.5), lineWidth: 3)
                    .blur(radius: 1)
                    .allowsHitTesting(false)
            }
            .frame(width: 160, height: 196)
        }
    }

    @ViewBuilder
    private var readyGlow: some View {
        if isReady {
            Circle()
                .fill(Color(hex: "F4C95D"))
                .frame(width: 150, height: 150)
                .blur(radius: 45)
                .opacity(glow ? 0.7 : 0.35)
                .offset(y: 30)
        }
    }

    private func paper(index: Int) -> some View {
        let jitterX = CGFloat((index * 37) % 28) - 14
        let angle = Double((index * 53) % 30) - 15
        return RoundedRectangle(cornerRadius: 3)
            .fill(index % 2 == 0 ? Color(hex: "FBF3E0") : Color(hex: "F2E7CE"))
            .frame(width: 78, height: 17)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.black.opacity(0.06), lineWidth: 1))
            .rotationEffect(.degrees(angle))
            .offset(x: jitterX, y: -CGFloat(index) * 6)
            .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
    }
}
