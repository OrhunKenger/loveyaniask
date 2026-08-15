//
//  KenHouseView.swift
//  Loveyaniask
//
//  Ken'in kulübesi. Sağ altta, zeminin üstünde sabit durur — Ken ekranda
//  görünmediğinde ("evde") nerede olduğunu bilmenizi sağlayan şey bu.
//  Ken gibi tek Canvas'ta çiziliyor; sabit olduğu için animasyonu yok.
//

import SwiftUI

struct KenHouseView: View {
    /// Ken uyuyorsa kulübe biraz daha sıcak görünsün.
    var isOccupied: Bool = false

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Gövde
            let walls = Path(
                roundedRect: CGRect(x: 0.10 * w, y: 0.36 * h, width: 0.80 * w, height: 0.64 * h),
                cornerRadius: 0.06 * w
            )
            context.fill(walls, with: .color(AppColors.surface))
            context.stroke(walls, with: .color(.white.opacity(0.14)), lineWidth: 1)

            // Çatı
            var roof = Path()
            roof.move(to: CGPoint(x: 0.02 * w, y: 0.40 * h))
            roof.addLine(to: CGPoint(x: 0.5 * w, y: 0.02 * h))
            roof.addLine(to: CGPoint(x: 0.98 * w, y: 0.40 * h))
            roof.closeSubpath()
            context.fill(
                roof,
                with: .linearGradient(
                    Gradient(colors: [AppColors.primary, AppColors.secondary]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: w, y: 0.4 * h)
                )
            )

            // Kapı — kemerli boşluk
            var door = Path()
            let doorW = 0.42 * w
            let doorTop = 0.52 * h
            door.move(to: CGPoint(x: 0.5 * w - doorW / 2, y: h))
            door.addLine(to: CGPoint(x: 0.5 * w - doorW / 2, y: doorTop + doorW / 2))
            door.addQuadCurve(
                to: CGPoint(x: 0.5 * w + doorW / 2, y: doorTop + doorW / 2),
                control: CGPoint(x: 0.5 * w, y: doorTop - doorW * 0.15)
            )
            door.addLine(to: CGPoint(x: 0.5 * w + doorW / 2, y: h))
            door.closeSubpath()
            context.fill(door, with: .color(.black.opacity(isOccupied ? 0.5 : 0.62)))

            if isOccupied {
                // İçeride bir şey var hissi: kapının içinde sıcak bir parıltı.
                context.fill(
                    Path(ellipseIn: CGRect(x: 0.5 * w - doorW * 0.3, y: 0.82 * h, width: doorW * 0.6, height: 0.1 * h)),
                    with: .color(AppColors.primary.opacity(0.35))
                )
            }
        }
        .allowsHitTesting(false)
    }
}
