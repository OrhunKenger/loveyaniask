//
//  KenCharacterView.swift
//  Loveyaniask
//
//  Ken'in gövdesi: yuvarlak gövde + kol/bacak + kaş/ağız/göz ile değişen bir
//  yüz ifadesi. Gövde rengi ruh hali tonuna göre sıcaktan soğuğa kayar
//  (bkz. KenCompanion.moodTone), ifade ise davranışa göre değişir; art arda
//  dokununca (KenCompanionView) "gıcık" ifadesine geçebilir.
//  Tüm çizim GeometryReader'ın verdiği boyuta göre orantılı (0...1) hesaplanır,
//  bu yüzden KenCompanionView onu istediği boyutta gösterebilir.
//

import SwiftUI

/// Gövdenin yumuşak, yuvarlak siluetini çizen özel Shape.
private struct KenBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: p(0.5, 0.20))
        path.addCurve(to: p(0.80, 0.43), control1: p(0.68, 0.20), control2: p(0.80, 0.29))
        path.addCurve(to: p(0.5, 0.80), control1: p(0.80, 0.62), control2: p(0.67, 0.80))
        path.addCurve(to: p(0.20, 0.43), control1: p(0.33, 0.80), control2: p(0.20, 0.62))
        path.addCurve(to: p(0.5, 0.20), control1: p(0.20, 0.29), control2: p(0.32, 0.20))
        path.closeSubpath()
        return path
    }
}

/// Bir kol, bacak ya da kaş: sabit bir noktadan (anchor), verilen açıda uzanan,
/// yuvarlak uçlu tek bir çizgi. `angle` animatable olduğu için `withAnimation`
/// içinde değiştirildiğinde SwiftUI otomatik ara kareler üretir.
private struct KenLimbShape: Shape {
    var angle: Angle
    let anchor: CGPoint
    let length: CGFloat

    var animatableData: Double {
        get { angle.degrees }
        set { angle = .degrees(newValue) }
    }

    func path(in rect: CGRect) -> Path {
        let rad = angle.radians
        let end = CGPoint(x: anchor.x + sin(rad) * length, y: anchor.y + cos(rad) * length)
        var path = Path()
        path.move(to: anchor)
        path.addLine(to: end)
        return path
    }
}

/// Ağız: `curve` pozitifse gülümseme (orta nokta aşağı bükülür), negatifse
/// kaş çatma/somurtma (orta nokta yukarı bükülür).
private struct KenMouthShape: Shape {
    var curve: CGFloat

    var animatableData: CGFloat {
        get { curve }
        set { curve = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let left = CGPoint(x: rect.minX + 0.42 * rect.width, y: rect.minY + 0.665 * rect.height)
        let right = CGPoint(x: rect.minX + 0.58 * rect.width, y: rect.minY + 0.665 * rect.height)
        let controlY = left.y + curve * 0.07 * rect.height
        let control = CGPoint(x: rect.minX + 0.5 * rect.width, y: controlY)
        var path = Path()
        path.move(to: left)
        path.addQuadCurve(to: right, control: control)
        return path
    }
}

/// Ken'in sergileyebileceği yüz ifadeleri. Davranışa göre varsayılanı seçilir;
/// art arda dokununca (bkz. KenCompanionView) geçici olarak `.annoyed`'e döner.
enum KenExpression {
    case sweet
    case content
    case laugh
    case love
    case annoyed

    /// Kaşların içe/dışa açısı — pozitif değer kaşları çatık (sinirli/gıcık) yapar.
    var eyebrowTilt: Double {
        switch self {
        case .sweet: -6
        case .content: -2
        case .laugh: -10
        case .love: -8
        case .annoyed: 16
        }
    }

    /// Ağız eğrisi: -1 (somurtma) ... 1 (geniş gülümseme).
    var mouthCurve: CGFloat {
        switch self {
        case .sweet: 0.55
        case .content: 0.3
        case .laugh: 1.0
        case .love: 0.7
        case .annoyed: -0.5
        }
    }

    /// Göz kısılma miktarı: 0 (tam açık) ... 1 (tamamen kısık).
    var eyeSquint: CGFloat {
        switch self {
        case .sweet: 0.1
        case .content: 0.05
        case .laugh: 0.5
        case .love: 0.15
        case .annoyed: 0.45
        }
    }

    /// Bir davranış sergilenirken varsayılan olarak takınacağı ifade.
    static func `default`(for behavior: KenBehavior) -> KenExpression {
        switch behavior {
        case .peek, .sit: .sweet
        case .dangle, .wander: .content
        case .bounce: .laugh
        case .greet, .introduce: .love
        }
    }
}

/// Ken'in tüm gövdesi: kollar, bacaklar, gövde, yüz ifadesi. `behavior` her
/// değiştiğinde çağıran taraf (KenCompanionView) bu view'ı `.id(behavior)`
/// ile yeniden kurar, böylece her davranış temiz bir animasyon durumuyla başlar.
struct KenCharacterView: View {
    let behavior: KenBehavior
    /// 0 (sıcak/olumlu) ... 1 (soğuk/zor) — nil ise varsayılan marka rengi kullanılır.
    var tone: Double? = nil
    /// Art arda dokunulunca dışarıdan (KenCompanionView) true yapılır.
    var annoyed: Bool = false

    @State private var legLeftAngle = Angle.degrees(-12)
    @State private var legRightAngle = Angle.degrees(12)
    @State private var armLeftAngle = Angle.degrees(-20)
    @State private var armRightAngle = Angle.degrees(20)
    @State private var bodyOffsetY: CGFloat = 0
    @State private var bodyScale: CGFloat = 1
    @State private var expression: KenExpression = .sweet

    private static let warmPrimary = (r: 255.0, g: 111.0, b: 165.0)   // AppColors.primary FF6FA5
    private static let warmSecondary = (r: 181.0, g: 71.0, b: 155.0)  // AppColors.secondary B5479B
    private static let coolPrimary = (r: 127.0, g: 160.0, b: 216.0)   // AppColors.fertile 7FA0D8
    private static let coolSecondary = (r: 126.0, g: 107.0, b: 240.0) // AppColors.ovulation 7E6BF0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let gradient = bodyGradient

            ZStack {
                limb(legLeftAngle, anchor: CGPoint(x: 0.38 * w, y: 0.79 * h), length: 0.22 * h, width: 0.085 * w, gradient: gradient)
                limb(legRightAngle, anchor: CGPoint(x: 0.62 * w, y: 0.79 * h), length: 0.22 * h, width: 0.085 * w, gradient: gradient)
                limb(armLeftAngle, anchor: CGPoint(x: 0.24 * w, y: 0.50 * h), length: 0.20 * h, width: 0.075 * w, gradient: gradient)

                KenBodyShape()
                    .fill(gradient)
                    .shadow(color: AppColors.primary.opacity(0.45), radius: 8, y: 3)
                    .overlay(face(w: w, h: h))
                    .offset(y: bodyOffsetY)
                    .scaleEffect(bodyScale)

                limb(armRightAngle, anchor: CGPoint(x: 0.76 * w, y: 0.50 * h), length: 0.20 * h, width: 0.075 * w, gradient: gradient)
            }
        }
        .onAppear {
            expression = annoyed ? .annoyed : .default(for: behavior)
            applyBehavior(behavior)
        }
        .onChange(of: annoyed) { _, isAnnoyed in
            withAnimation(.easeInOut(duration: 0.3)) {
                expression = isAnnoyed ? .annoyed : .default(for: behavior)
            }
        }
    }

    /// Marka renginden (sıcak) mood-tonuna göre soğuğa kayan gövde/uzuv gradyanı.
    private var bodyGradient: LinearGradient {
        guard let tone else { return AppColors.accentGradient }
        let t = min(max(tone, 0), 1)
        func mix(_ warm: (r: Double, g: Double, b: Double), _ cool: (r: Double, g: Double, b: Double)) -> Color {
            Color(
                .sRGB,
                red: (warm.r + (cool.r - warm.r) * t) / 255,
                green: (warm.g + (cool.g - warm.g) * t) / 255,
                blue: (warm.b + (cool.b - warm.b) * t) / 255,
                opacity: 1
            )
        }
        return LinearGradient(
            colors: [mix(Self.warmPrimary, Self.coolPrimary), mix(Self.warmSecondary, Self.coolSecondary)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    private func limb(_ angle: Angle, anchor: CGPoint, length: CGFloat, width: CGFloat, gradient: LinearGradient) -> some View {
        KenLimbShape(angle: angle, anchor: anchor, length: length)
            .stroke(gradient, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }

    private func face(w: CGFloat, h: CGFloat) -> some View {
        let inkColor = Color(hex: "2B1C22").opacity(0.8)
        let browAngle = expression.eyebrowTilt

        return ZStack {
            Ellipse()
                .fill(.white.opacity(0.32))
                .frame(width: 0.18 * w, height: 0.11 * h)
                .position(x: 0.40 * w, y: 0.36 * h)
            Ellipse()
                .fill(.white.opacity(0.18))
                .frame(width: 0.12 * w, height: 0.06 * h)
                .position(x: 0.32 * w, y: 0.62 * h)
            Ellipse()
                .fill(.white.opacity(0.18))
                .frame(width: 0.12 * w, height: 0.06 * h)
                .position(x: 0.68 * w, y: 0.62 * h)

            // Kaşlar — dış uçtan (anchor) iç uca uzanır; pozitif `browAngle` iç ucu
            // aşağı çekip çatık (sinirli/gıcık), negatif değer yukarı kaldırıp
            // yumuşatır (tatlı/mutlu).
            KenLimbShape(angle: .degrees(90 - browAngle), anchor: CGPoint(x: 0.32 * w, y: 0.45 * h), length: 0.12 * w)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.018 * w, lineCap: .round))
            KenLimbShape(angle: .degrees(-90 + browAngle), anchor: CGPoint(x: 0.68 * w, y: 0.45 * h), length: 0.12 * w)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.018 * w, lineCap: .round))

            Circle()
                .fill(inkColor)
                .frame(width: 0.07 * w, height: 0.07 * w)
                .scaleEffect(y: 1 - expression.eyeSquint)
                .position(x: 0.42 * w, y: 0.52 * h)
            Circle()
                .fill(inkColor)
                .frame(width: 0.07 * w, height: 0.07 * w)
                .scaleEffect(y: 1 - expression.eyeSquint)
                .position(x: 0.60 * w, y: 0.52 * h)

            KenMouthShape(curve: expression.mouthCurve)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.02 * w, lineCap: .round))
                .frame(width: w, height: h)
        }
    }

    /// Her davranış için hangi uzuvların, hangi ritimde sallanacağını belirler.
    private func applyBehavior(_ behavior: KenBehavior) {
        switch behavior {
        case .peek:
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                armRightAngle = .degrees(-60)
            }
        case .dangle:
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                legLeftAngle = .degrees(-22)
                legRightAngle = .degrees(22)
            }
        case .wander:
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                legLeftAngle = .degrees(30)
                armRightAngle = .degrees(30)
            }
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true).delay(0.175)) {
                legRightAngle = .degrees(-30)
                armLeftAngle = .degrees(-30)
            }
        case .sit:
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                legLeftAngle = .degrees(-26)
                legRightAngle = .degrees(26)
            }
        case .bounce:
            withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                armLeftAngle = .degrees(-100)
                armRightAngle = .degrees(100)
                bodyOffsetY = -14
                bodyScale = 1.05
            }
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                legLeftAngle = .degrees(-18)
                legRightAngle = .degrees(18)
            }
        case .greet, .introduce:
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                armRightAngle = .degrees(-70)
                bodyOffsetY = -6
            }
        }
    }
}
