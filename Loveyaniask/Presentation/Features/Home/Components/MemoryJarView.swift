//
//  MemoryJarView.swift
//  Loveyaniask
//
//  Gerçeksi cam kavanoz: not eklendikçe içine kâğıtlar dolar.
//  `scale` ile küçültülüp ana sayfada az yer kaplayacak şekilde kullanılır.
//

import SwiftUI

struct MemoryJarView: View {
    let count: Int
    var isReady: Bool = false
    var scale: CGFloat = 1

    private var displayed: Int { min(count, 24) }

    private var glassFill: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.55), Color(hex: "CBD8EE").opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        jar
            .scaleEffect(scale, anchor: .center)
            .frame(width: 160 * scale, height: 230 * scale)
            .background(readyGlow)
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
            // Statik parıltı: bir kez çizilir, GPU boşta kalır (eskiden sonsuz
            // animasyonlu 40pt blur idi → telefonu ısıtan ana sebepti).
            Circle()
                .fill(Color(hex: "F4C95D"))
                .frame(width: 140 * scale, height: 140 * scale)
                .blur(radius: 40)
                .opacity(0.5)
                .offset(y: 25 * scale)
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
