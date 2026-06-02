//
//  MemoryJarView.swift
//  Loveyaniask
//
//  Gerçeksi cam kavanoz: not eklendikçe içine kâğıtlar dolar.
//

import SwiftUI

struct MemoryJarView: View {
    let count: Int

    private var displayed: Int { min(count, 20) }

    private var glassFill: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.6), Color(hex: "D7E0F0").opacity(0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: -4) {
            // Kapak
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 96, height: 22)
                .zIndex(1)

            // Boğaz
            RoundedRectangle(cornerRadius: 4)
                .fill(glassFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.white.opacity(0.6), lineWidth: 1)
                )
                .frame(width: 78, height: 14)

            // Gövde
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(glassFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(.white.opacity(0.7), lineWidth: 1.5)
                    )

                // Kâğıtlar
                ZStack(alignment: .bottom) {
                    ForEach(0..<displayed, id: \.self) { index in
                        paper(index: index)
                    }
                }
                .padding(.bottom, 16)

                // Parlama
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            }
            .frame(width: 152, height: 188)
        }
    }

    private func paper(index: Int) -> some View {
        let jitterX = CGFloat((index * 37) % 30) - 15
        let angle = Double((index * 53) % 30) - 15
        return RoundedRectangle(cornerRadius: 3)
            .fill(index % 2 == 0 ? Color(hex: "FBF3E0") : Color(hex: "F2E7CE"))
            .frame(width: 74, height: 18)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.black.opacity(0.06), lineWidth: 1)
            )
            .rotationEffect(.degrees(angle))
            .offset(x: jitterX, y: -CGFloat(index) * 7)
            .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
    }
}
