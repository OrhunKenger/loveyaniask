//
//  KenCharacterView.swift
//  Loveyaniask
//
//  Ken'in gövdesi: yuvarlak gövde + kol/bacak/kuyruk + kaş/göz/ağız ile değişen
//  bir yüz ifadesi. Gövde rengi ruh hali tonuna göre sıcaktan soğuğa kayar
//  (bkz. KenCompanion.moodTone), ifade ise davranışa göre değişir; art arda
//  dokununca (KenStage) "gıcık" ifadesine geçebilir.
//
//  Hareket, SwiftUI animasyonlarıyla değil, sürekli zamanın fonksiyonu olarak
//  üretiliyor (bkz. KenMotion): TimelineView her karede o anki KenFrame'i
//  hesaplıyor. Davranış değiştiğinde view sıfırlanmıyor — eski ve yeni davranışın
//  kareleri yarım saniye boyunca harmanlanıyor, böylece geçiş yumuşak akıyor.
//
//  PERFORMANS: Tüm çizim TEK bir Canvas içinde yapılıyor. Önce ayrı ayrı
//  Shape/Ellipse view'ları vardı; her karede ~15 katmanlık view ağacı yeniden
//  kuruluyor, gradyan stroke'lar + drop shadow + blur ekstra offscreen render
//  geçişlerine yol açıyordu ve uygulama gözle görülür şekilde kasıyordu.
//  Canvas'ta hepsi tek geçişte çiziliyor; blur/gölge filtresi kullanılmıyor.
//  Bu yüzden buraya .shadow/.blur eklemeyin — kasmanın sebebi tam olarak oydu.
//

import SwiftUI

/// Ken'in parçalarının yol (Path) tanımları. Hepsi 0...1 oranlı, yani view
/// hangi boyutta olursa olsun aynı siluet çıkıyor.
private enum KenPath {
    static func body(in rect: CGRect) -> Path {
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

    /// Bir kol, bacak ya da kaş: sabit bir noktadan verilen açıda uzanan tek çizgi.
    /// Açı 0 = aşağı, 90 = sağa, -90 = sola, 180 = yukarı.
    static func limb(anchor: CGPoint, degrees: Double, length: CGFloat) -> Path {
        let rad = Angle.degrees(degrees).radians
        var path = Path()
        path.move(to: anchor)
        path.addLine(to: CGPoint(x: anchor.x + sin(rad) * length, y: anchor.y + cos(rad) * length))
        return path
    }

    /// Gövdenin arkasından çıkan kuyruk. `curl` yukarı kalkıklığı belirler:
    /// keyifliyken yukarı kıvrılıp sallanır, uykuluyken aşağı sarkar.
    static func tail(in rect: CGRect, curl: CGFloat) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: p(0.68, 0.73))
        path.addQuadCurve(to: p(0.90, 0.56 - 0.13 * curl), control: p(0.93, 0.74 - 0.09 * curl))
        return path
    }

    /// Ağız: `curve` pozitifse gülümseme, negatifse somurtma.
    static func mouth(in rect: CGRect, curve: CGFloat) -> Path {
        let left = CGPoint(x: rect.minX + 0.42 * rect.width, y: rect.minY + 0.665 * rect.height)
        let right = CGPoint(x: rect.minX + 0.58 * rect.width, y: rect.minY + 0.665 * rect.height)
        let control = CGPoint(x: rect.minX + 0.5 * rect.width, y: left.y + curve * 0.07 * rect.height)
        var path = Path()
        path.move(to: left)
        path.addQuadCurve(to: right, control: control)
        return path
    }

    /// Merkezi verilen elips (göz, yanak, parıltı).
    static func ellipse(center: CGPoint, width: CGFloat, height: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height))
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
/// art arda dokununca (bkz. KenStage) geçici olarak `.annoyed`'e döner.
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
        case .held: .longing
        case .dizzy: .sleepy
        case .grumble: .annoyed
        }
    }
}

/// Ken'in tüm gövdesi. Davranış değişse bile bu view yeniden kurulmaz —
/// geçişi kendi içinde harmanlar (bkz. KenMotion).
struct KenCharacterView: View {
    let behavior: KenBehavior
    /// 0 (sıcak/olumlu) ... 1 (soğuk/zor) — nil ise varsayılan marka rengi kullanılır.
    var tone: Double? = nil
    /// Art arda dokunulunca dışarıdan (KenStage) true yapılır.
    var annoyed: Bool = false
    /// Görünmezken hareket motoru duruyor — boşuna kare üretmesin diye.
    var isVisible: Bool = true
    /// Saniyedeki kare sayısı. Ana sayfadaki minik Ken sürekli ekranda durduğu
    /// için çok daha düşük bir hızla çiziliyor.
    var fps: Double = 30

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
    private static let ink = Color(hex: "2B1C22").opacity(0.8)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / fps, paused: !isVisible)) { timeline in
            Canvas(rendersAsynchronously: false) { context, size in
                draw(in: &context, size: size, at: timeline.date)
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

    // MARK: - Çizim

    private func draw(in context: inout GraphicsContext, size: CGSize, at now: Date) {
        let w = size.width
        let h = size.height
        let rect = CGRect(origin: .zero, size: size)
        let frame = resolvedFrame(at: now)
        let face = resolvedFace(at: now)
        let blink = KenMotion.blink(at: now.timeIntervalSinceReferenceDate)

        // Yer gölgesi: gövde dönüşümlerinden ETKİLENMEMELİ, o yüzden önce ve
        // dönüşümler uygulanmadan çiziliyor. Zıpladıkça küçülüp soluyor —
        // Ken'in bir zemine bastığı hissini veren en ucuz numara.
        let air = min(max(-frame.lift, 0) / 0.3, 1)
        let k = 1 - 0.55 * air
        context.fill(
            KenPath.ellipse(center: CGPoint(x: 0.5 * w, y: 0.975 * h), width: 0.42 * w * k, height: 0.055 * h * k),
            with: .color(.black.opacity(0.26 * Double(k)))
        )

        // Gövde dönüşümleri (yükselme + çömelme + eğim), taban ortasına göre.
        context.translateBy(x: 0, y: frame.lift * h)
        context.translateBy(x: 0.5 * w, y: h)
        context.rotate(by: .degrees(frame.lean))
        context.scaleBy(x: 1 + frame.squash * 0.5, y: 1 - frame.squash)
        context.translateBy(x: -0.5 * w, y: -h)

        let shading = bodyShading(w: w, h: h)
        let inkShading = GraphicsContext.Shading.color(Self.ink)

        context.stroke(
            KenPath.tail(in: rect, curl: CGFloat(frame.tail)),
            with: shading,
            style: StrokeStyle(lineWidth: 0.055 * w, lineCap: .round)
        )

        let legStyle = StrokeStyle(lineWidth: 0.085 * w, lineCap: .round)
        let armStyle = StrokeStyle(lineWidth: 0.075 * w, lineCap: .round)
        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.38 * w, y: 0.79 * h), degrees: frame.legLeft, length: 0.22 * h), with: shading, style: legStyle)
        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.62 * w, y: 0.79 * h), degrees: frame.legRight, length: 0.22 * h), with: shading, style: legStyle)
        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.24 * w, y: 0.50 * h), degrees: frame.armLeft, length: 0.20 * h), with: shading, style: armStyle)

        context.fill(KenPath.body(in: rect), with: shading)

        drawFace(in: &context, w: w, h: h, rect: rect, frame: frame, face: face, blink: blink, ink: inkShading)

        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.76 * w, y: 0.50 * h), degrees: frame.armRight, length: 0.20 * h), with: shading, style: armStyle)
    }

    private func drawFace(in context: inout GraphicsContext, w: CGFloat, h: CGFloat, rect: CGRect, frame: KenFrame, face: KenFace, blink: CGFloat, ink: GraphicsContext.Shading) {
        // Gövde üstündeki ışık lekesi + yanaklar (gülümseme arttıkça belirginleşir).
        context.fill(
            KenPath.ellipse(center: CGPoint(x: 0.40 * w, y: 0.36 * h), width: 0.18 * w, height: 0.11 * h),
            with: .color(.white.opacity(0.3))
        )
        let blush = 0.16 + 0.16 * Double(max(0, face.mouthCurve))
        context.fill(
            KenPath.ellipse(center: CGPoint(x: 0.32 * w, y: 0.62 * h), width: 0.12 * w, height: 0.06 * h),
            with: .color(.white.opacity(blush))
        )
        context.fill(
            KenPath.ellipse(center: CGPoint(x: 0.68 * w, y: 0.62 * h), width: 0.12 * w, height: 0.06 * h),
            with: .color(.white.opacity(blush))
        )

        // Kaşlar — dış uçtan iç uca uzanır; pozitif tilt iç ucu aşağı çekip
        // çatık (gıcık), negatif değer yukarı kaldırıp yumuşatır.
        let browStyle = StrokeStyle(lineWidth: 0.018 * w, lineCap: .round)
        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.32 * w, y: 0.45 * h), degrees: 90 - face.browTilt, length: 0.12 * w), with: ink, style: browStyle)
        context.stroke(KenPath.limb(anchor: CGPoint(x: 0.68 * w, y: 0.45 * h), degrees: -90 + face.browTilt, length: 0.12 * w), with: ink, style: browStyle)

        // Gözler: kapak açıklığı ifadeden ve göz kırpmadan geliyor, ikisi çarpılıyor.
        let eyeOpen = max(0.04, (1 - face.eyeSquint) * frame.eyeOpen * (1 - blink))
        let eyeSize = 0.07 * w
        let eyeY = 0.52 * h + frame.gazeY * 0.018 * h
        for eyeX in [0.42 * w, 0.60 * w] {
            let center = CGPoint(x: eyeX + frame.gazeX * 0.022 * w, y: eyeY)
            context.fill(
                KenPath.ellipse(center: center, width: eyeSize, height: eyeSize * eyeOpen),
                with: ink
            )
            if eyeOpen > 0.45 {
                context.fill(
                    KenPath.ellipse(
                        center: CGPoint(x: center.x - eyeSize * 0.18, y: center.y - eyeSize * 0.2 * eyeOpen),
                        width: eyeSize * 0.3,
                        height: eyeSize * 0.3 * eyeOpen
                    ),
                    with: .color(.white.opacity(0.85))
                )
            }
        }

        // Ağız: kapalıyken eğri çizgi, açılınca dolu elips — ikisi arasında geçiş.
        if frame.mouthOpen < 0.98 {
            var closed = context
            closed.opacity = 1 - Double(frame.mouthOpen)
            closed.stroke(
                KenPath.mouth(in: rect, curve: face.mouthCurve),
                with: ink,
                style: StrokeStyle(lineWidth: 0.02 * w, lineCap: .round)
            )
        }
        if frame.mouthOpen > 0.02 {
            var open = context
            open.opacity = Double(frame.mouthOpen)
            open.fill(
                KenPath.ellipse(
                    center: CGPoint(x: 0.5 * w, y: 0.675 * h),
                    width: 0.10 * w + 0.035 * w * frame.mouthOpen,
                    height: 0.012 * h + 0.055 * h * frame.mouthOpen
                ),
                with: ink
            )
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

    /// Marka renginden (sıcak) mood-tonuna göre soğuğa kayan gövde/uzuv gradyanı.
    private func bodyShading(w: CGFloat, h: CGFloat) -> GraphicsContext.Shading {
        let t = min(max(tone ?? 0, 0), 1)
        func mix(_ warm: (r: Double, g: Double, b: Double), _ cool: (r: Double, g: Double, b: Double)) -> Color {
            Color(
                .sRGB,
                red: (warm.r + (cool.r - warm.r) * t) / 255,
                green: (warm.g + (cool.g - warm.g) * t) / 255,
                blue: (warm.b + (cool.b - warm.b) * t) / 255,
                opacity: 1
            )
        }
        return .linearGradient(
            Gradient(colors: [mix(Self.warmPrimary, Self.coolPrimary), mix(Self.warmSecondary, Self.coolSecondary)]),
            startPoint: .zero,
            endPoint: CGPoint(x: w, y: h)
        )
    }
}
