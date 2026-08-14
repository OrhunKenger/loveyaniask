//
//  KenCharacterView.swift
//  Loveyaniask
//
//  Ken'in gövdesi: yuvarlak gövde + kol/bacak/kuyruk + kaş/göz/ağız ile değişen
//  bir yüz ifadesi. Gövde rengi ruh hali tonuna göre sıcaktan soğuğa kayar
//  (bkz. KenCompanion.moodTone), ifade ise davranışa göre değişir; art arda
//  dokununca (KenCompanionView) "gıcık" ifadesine geçebilir.
//
//  Hareket, SwiftUI animasyonlarıyla değil, sürekli zamanın fonksiyonu olarak
//  üretiliyor (bkz. KenMotion): TimelineView her karede o anki KenFrame'i
//  hesaplıyor. Davranış değiştiğinde view sıfırlanmıyor — eski ve yeni davranışın
//  kareleri yarım saniye boyunca harmanlanıyor, böylece geçiş yumuşak akıyor.
//  Tüm çizim GeometryReader'ın verdiği boyuta göre orantılı (0...1) hesaplanır.
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
/// yuvarlak uçlu tek bir çizgi.
private struct KenLimbShape: Shape {
    var angle: Angle
    let anchor: CGPoint
    let length: CGFloat

    func path(in rect: CGRect) -> Path {
        let rad = angle.radians
        let end = CGPoint(x: anchor.x + sin(rad) * length, y: anchor.y + cos(rad) * length)
        var path = Path()
        path.move(to: anchor)
        path.addLine(to: end)
        return path
    }
}

/// Gövdenin arkasından çıkan kuyruk. `curl` yukarı kalkıklığı belirler:
/// keyifliyken yukarı kıvrılıp sallanır, uykuluyken aşağı sarkar.
private struct KenTailShape: Shape {
    var curl: CGFloat

    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: p(0.68, 0.73))
        path.addQuadCurve(to: p(0.90, 0.56 - 0.13 * curl), control: p(0.93, 0.74 - 0.09 * curl))
        return path
    }
}

/// Ağız: `curve` pozitifse gülümseme (orta nokta aşağı bükülür), negatifse
/// somurtma (orta nokta yukarı bükülür).
private struct KenMouthShape: Shape {
    var curve: CGFloat

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

/// Yüzün o anki sayısal hâli. İfadeler arası geçiş bu üç sayının
/// harmanlanmasıyla oluyor (ani sıçrama yok).
struct KenFace {
    var browTilt: Double
    var mouthCurve: CGFloat
    var eyeSquint: CGFloat

    static func blend(_ a: KenFace, _ b: KenFace, _ progress: Double) -> KenFace {
        let t = min(max(progress, 0), 1)
        return KenFace(
            browTilt: a.browTilt + (b.browTilt - a.browTilt) * t,
            mouthCurve: a.mouthCurve + (b.mouthCurve - a.mouthCurve) * CGFloat(t),
            eyeSquint: a.eyeSquint + (b.eyeSquint - a.eyeSquint) * CGFloat(t)
        )
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
    /// Uykulu: gözler neredeyse kapalı, ağız minik.
    case sleepy
    /// Özlemiş: kaşların iç ucu yukarıda, gözler kocaman — asla kızgın değil.
    case longing

    /// Kaşların içe/dışa açısı — pozitif değer kaşları çatık (sinirli/gıcık) yapar.
    var eyebrowTilt: Double {
        switch self {
        case .sweet: -6
        case .content: -2
        case .laugh: -10
        case .love: -8
        case .annoyed: 16
        case .sleepy: -3
        case .longing: -15
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
        case .sleepy: 0.15
        case .longing: 0.12
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
        case .sleepy: 0.75
        case .longing: 0
        }
    }

    var face: KenFace {
        KenFace(browTilt: eyebrowTilt, mouthCurve: mouthCurve, eyeSquint: eyeSquint)
    }

    /// Bir davranış sergilenirken varsayılan olarak takınacağı ifade.
    static func `default`(for behavior: KenBehavior) -> KenExpression {
        switch behavior {
        case .peek, .sit: .sweet
        case .dangle, .wander, .stretch: .content
        case .bounce, .celebrate: .laugh
        case .greet, .introduce: .love
        case .snooze: .sleepy
        case .miss: .longing
        }
    }
}

/// Ken'in tüm gövdesi. Davranış değişse bile bu view yeniden kurulmaz —
/// geçişi kendi içinde harmanlar (bkz. KenMotion).
struct KenCharacterView: View {
    let behavior: KenBehavior
    /// 0 (sıcak/olumlu) ... 1 (soğuk/zor) — nil ise varsayılan marka rengi kullanılır.
    var tone: Double? = nil
    /// Art arda dokunulunca dışarıdan (KenCompanionView) true yapılır.
    var annoyed: Bool = false
    /// Görünmezken hareket motoru duruyor — boşuna kare üretmesin diye.
    var isVisible: Bool = true
    /// Saniyedeki kare sayısı. Ana sayfadaki minik Ken sürekli ekranda durduğu
    /// için daha düşük bir hızla çiziliyor.
    var fps: Double = 60

    @State private var previousBehavior: KenBehavior = .peek
    @State private var currentBehavior: KenBehavior = .peek
    @State private var previousStart = Date()
    @State private var currentStart = Date()
    @State private var switchedAt = Date.distantPast
    @State private var annoyedChangedAt = Date.distantPast

    private static let warmPrimary = (r: 255.0, g: 111.0, b: 165.0)   // AppColors.primary FF6FA5
    private static let warmSecondary = (r: 181.0, g: 71.0, b: 155.0)  // AppColors.secondary B5479B
    private static let coolPrimary = (r: 127.0, g: 160.0, b: 216.0)   // AppColors.fertile 7FA0D8
    private static let coolSecondary = (r: 126.0, g: 107.0, b: 240.0) // AppColors.ovulation 7E6BF0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let gradient = bodyGradient

            TimelineView(.animation(minimumInterval: 1.0 / fps, paused: !isVisible)) { context in
                let now = context.date
                let frame = resolvedFrame(at: now)
                let face = resolvedFace(at: now)
                let blink = KenMotion.blink(at: now.timeIntervalSinceReferenceDate)

                ZStack {
                    groundShadow(w: w, h: h, lift: frame.lift)

                    character(w: w, h: h, frame: frame, face: face, blink: blink, gradient: gradient)
                        .offset(y: frame.lift * h)
                        .scaleEffect(x: 1 + frame.squash * 0.5, y: 1 - frame.squash, anchor: .bottom)
                        .rotationEffect(.degrees(frame.lean), anchor: .bottom)
                }
            }
        }
        .onAppear {
            previousBehavior = behavior
            currentBehavior = behavior
            let now = Date()
            previousStart = now
            currentStart = now
        }
        .onChange(of: behavior) { _, newValue in
            let now = Date()
            previousBehavior = currentBehavior
            previousStart = currentStart
            currentBehavior = newValue
            currentStart = now
            switchedAt = now
        }
        .onChange(of: annoyed) { _, _ in
            annoyedChangedAt = Date()
        }
    }

    // MARK: - O anki hâlin hesabı

    private func resolvedFrame(at now: Date) -> KenFrame {
        let current = KenMotion.frame(for: currentBehavior, elapsed: now.timeIntervalSince(currentStart))
        let t = now.timeIntervalSince(switchedAt) / KenMotion.transition
        guard t < 1 else { return current }
        let previous = KenMotion.frame(for: previousBehavior, elapsed: now.timeIntervalSince(previousStart))
        return KenFrame.blend(previous, current, KenMotion.ease(t))
    }

    private func resolvedFace(at now: Date) -> KenFace {
        let t = now.timeIntervalSince(switchedAt) / KenMotion.transition
        let base = t < 1
            ? KenFace.blend(
                KenExpression.default(for: previousBehavior).face,
                KenExpression.default(for: currentBehavior).face,
                KenMotion.ease(t)
              )
            : KenExpression.default(for: currentBehavior).face

        let k = KenMotion.ease(now.timeIntervalSince(annoyedChangedAt) / 0.28)
        let amount = annoyed ? k : 1 - k
        guard amount > 0 else { return base }
        return KenFace.blend(base, KenExpression.annoyed.face, amount)
    }

    // MARK: - Çizim

    /// Zıpladıkça küçülüp solan yer gölgesi — Ken'in bir zemine bastığı hissini
    /// veren en ucuz numara.
    private func groundShadow(w: CGFloat, h: CGFloat, lift: CGFloat) -> some View {
        let air = min(max(-lift, 0) / 0.3, 1)
        let k = 1 - 0.55 * air
        return Ellipse()
            .fill(Color.black.opacity(0.3 * Double(k)))
            .frame(width: 0.44 * w * k, height: 0.065 * h * k)
            .position(x: 0.5 * w, y: 0.975 * h)
            .blur(radius: 3)
    }

    private func character(w: CGFloat, h: CGFloat, frame: KenFrame, face: KenFace, blink: CGFloat, gradient: LinearGradient) -> some View {
        ZStack {
            KenTailShape(curl: CGFloat(frame.tail))
                .stroke(gradient, style: StrokeStyle(lineWidth: 0.055 * w, lineCap: .round))

            limb(frame.legLeft, anchor: CGPoint(x: 0.38 * w, y: 0.79 * h), length: 0.22 * h, width: 0.085 * w, gradient: gradient)
            limb(frame.legRight, anchor: CGPoint(x: 0.62 * w, y: 0.79 * h), length: 0.22 * h, width: 0.085 * w, gradient: gradient)
            limb(frame.armLeft, anchor: CGPoint(x: 0.24 * w, y: 0.50 * h), length: 0.20 * h, width: 0.075 * w, gradient: gradient)

            KenBodyShape()
                .fill(gradient)
                .shadow(color: AppColors.primary.opacity(0.45), radius: 8, y: 3)
                .overlay(faceLayer(w: w, h: h, frame: frame, face: face, blink: blink))

            limb(frame.armRight, anchor: CGPoint(x: 0.76 * w, y: 0.50 * h), length: 0.20 * h, width: 0.075 * w, gradient: gradient)
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

    private func limb(_ degrees: Double, anchor: CGPoint, length: CGFloat, width: CGFloat, gradient: LinearGradient) -> some View {
        KenLimbShape(angle: .degrees(degrees), anchor: anchor, length: length)
            .stroke(gradient, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }

    private func faceLayer(w: CGFloat, h: CGFloat, frame: KenFrame, face: KenFace, blink: CGFloat) -> some View {
        let inkColor = Color(hex: "2B1C22").opacity(0.8)
        let browAngle = face.browTilt
        // Gülümseme arttıkça yanaklar da belirginleşiyor.
        let blushOpacity = 0.16 + 0.16 * Double(max(0, face.mouthCurve))
        let eyeOpen = max(0.04, (1 - face.eyeSquint) * frame.eyeOpen * (1 - blink))
        let eyeSize = 0.07 * w

        return ZStack {
            Ellipse()
                .fill(.white.opacity(0.32))
                .frame(width: 0.18 * w, height: 0.11 * h)
                .position(x: 0.40 * w, y: 0.36 * h)
            Ellipse()
                .fill(.white.opacity(blushOpacity))
                .frame(width: 0.12 * w, height: 0.06 * h)
                .position(x: 0.32 * w, y: 0.62 * h)
            Ellipse()
                .fill(.white.opacity(blushOpacity))
                .frame(width: 0.12 * w, height: 0.06 * h)
                .position(x: 0.68 * w, y: 0.62 * h)

            // Kaşlar — dış uçtan (anchor) iç uca uzanır; pozitif `browAngle` iç ucu
            // aşağı çekip çatık (sinirli/gıcık), negatif değer yukarı kaldırıp
            // yumuşatır (tatlı/mutlu/özlemiş).
            KenLimbShape(angle: .degrees(90 - browAngle), anchor: CGPoint(x: 0.32 * w, y: 0.45 * h), length: 0.12 * w)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.018 * w, lineCap: .round))
            KenLimbShape(angle: .degrees(-90 + browAngle), anchor: CGPoint(x: 0.68 * w, y: 0.45 * h), length: 0.12 * w)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.018 * w, lineCap: .round))

            eye(size: eyeSize, open: eyeOpen, ink: inkColor)
                .position(x: 0.42 * w + frame.gazeX * 0.022 * w, y: 0.52 * h + frame.gazeY * 0.018 * h)
            eye(size: eyeSize, open: eyeOpen, ink: inkColor)
                .position(x: 0.60 * w + frame.gazeX * 0.022 * w, y: 0.52 * h + frame.gazeY * 0.018 * h)

            KenMouthShape(curve: face.mouthCurve)
                .stroke(inkColor, style: StrokeStyle(lineWidth: 0.02 * w, lineCap: .round))
                .frame(width: w, height: h)
                .opacity(1 - Double(frame.mouthOpen))

            Ellipse()
                .fill(inkColor)
                .frame(width: 0.10 * w + 0.035 * w * frame.mouthOpen, height: 0.012 * h + 0.055 * h * frame.mouthOpen)
                .position(x: 0.5 * w, y: 0.675 * h)
                .opacity(Double(frame.mouthOpen))
        }
    }

    /// Göz: koyu bebek + küçük beyaz parıltı. `open` hem ifadeden hem göz
    /// kırpmadan gelir, ikisi çarpılarak tek bir kapak açıklığına dönüşür.
    private func eye(size: CGFloat, open: CGFloat, ink: Color) -> some View {
        ZStack {
            Circle()
                .fill(ink)
            Circle()
                .fill(.white.opacity(0.85))
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(x: -size * 0.18, y: -size * 0.2)
        }
        .frame(width: size, height: size)
        .scaleEffect(y: open, anchor: .center)
    }
}
