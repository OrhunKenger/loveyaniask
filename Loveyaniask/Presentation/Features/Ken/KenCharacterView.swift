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
//  Canvas'ta hepsi tek geçişte çiziliyor. Gölge/parıltı gerektiğinde blur
//  filtresi yerine radyal gradyan kullanılıyor: aynı görüntü, her karede
//  ekran dışı render geçişi olmadan.
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

    /// Kulak: tepede, dışa doğru eğik yaprak biçimi. Küçük tutuluyor —
    /// büyüğü Ken'i "kedi çizimi"ne çevirir, soyut sevimliliğini kaybeder.
    static func ear(in rect: CGRect, atX x: CGFloat, tilt: CGFloat) -> Path {
        func p(_ px: CGFloat, _ py: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + px * rect.width, y: rect.minY + py * rect.height)
        }
        var path = Path()
        path.move(to: p(x, 0.255))
        path.addQuadCurve(to: p(x + tilt * 0.085, 0.115), control: p(x + tilt * 0.10, 0.20))
        path.addQuadCurve(to: p(x + tilt * 0.005, 0.245), control: p(x - tilt * 0.02, 0.185))
        path.closeSubpath()
        return path
    }

    /// Uzuv: kökte kalın, uçta ince. Sabit kalınlıktaki çizgi "şema" okur;
    /// incelen bir şekil organik okur — karakterin en ucuz canlılık kaynağı.
    /// Açı 0 = aşağı, 90 = sağa, -90 = sola, 180 = yukarı.
    static func limb(anchor: CGPoint, degrees: Double, length: CGFloat,
                     rootWidth: CGFloat, tipWidth: CGFloat) -> (path: Path, tip: CGPoint, direction: CGVector) {
        let rad = Angle.degrees(degrees).radians
        let dir = CGVector(dx: sin(rad), dy: cos(rad))
        let perp = CGVector(dx: -dir.dy, dy: dir.dx)
        let tip = CGPoint(x: anchor.x + dir.dx * length, y: anchor.y + dir.dy * length)

        func offset(_ point: CGPoint, _ amount: CGFloat) -> CGPoint {
            CGPoint(x: point.x + perp.dx * amount, y: point.y + perp.dy * amount)
        }
        let r = rootWidth / 2, t = tipWidth / 2
        var path = Path()
        path.move(to: offset(anchor, r))
        path.addLine(to: offset(tip, t))
        path.addQuadCurve(
            to: offset(tip, -t),
            control: CGPoint(x: tip.x + dir.dx * t * 1.6, y: tip.y + dir.dy * t * 1.6)
        )
        path.addLine(to: offset(anchor, -r))
        path.addQuadCurve(
            to: offset(anchor, r),
            control: CGPoint(x: anchor.x - dir.dx * r * 1.2, y: anchor.y - dir.dy * r * 1.2)
        )
        path.closeSubpath()
        return (path, tip, dir)
    }

    /// Pati: uzvun ucundaki yastık. Ken'in imzası 🐾 ama pençesi yoktu —
    /// bu, karakterin en görünür tutarsızlığıydı.
    static func paw(at tip: CGPoint, direction: CGVector, size: CGFloat) -> Path {
        let center = CGPoint(x: tip.x + direction.dx * size * 0.18, y: tip.y + direction.dy * size * 0.18)
        return Path(ellipseIn: CGRect(x: center.x - size * 0.5, y: center.y - size * 0.42,
                                      width: size, height: size * 0.84))
    }

    /// Kuyruk gövdesi: incelen bir eğri. Ucundaki kalp ayrı çiziliyor.
    static func tail(in rect: CGRect, curl: CGFloat) -> (path: Path, tip: CGPoint) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        let start = p(0.66, 0.74)
        let end = p(0.88, 0.58 - 0.13 * curl)
        let control = p(0.93, 0.76 - 0.09 * curl)
        let width = rect.width * 0.055

        // Incelen kuyruk: eğrinin iki yanından, uca doğru daralarak.
        var path = Path()
        path.move(to: CGPoint(x: start.x, y: start.y - width / 2))
        path.addQuadCurve(to: end, control: CGPoint(x: control.x - width * 0.2, y: control.y - width * 0.5))
        path.addQuadCurve(to: CGPoint(x: start.x, y: start.y + width / 2),
                          control: CGPoint(x: control.x + width * 0.2, y: control.y + width * 0.5))
        path.closeSubpath()
        return (path, end)
    }

    /// Kuyruğun ucundaki kalp — Ken'i siluetinden tanınır kılan tek detay,
    /// ve uygulamanın konusuyla doğrudan bağı.
    static func heart(center: CGPoint, size: CGFloat) -> Path {
        let w = size, h = size
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y + h * 0.45))
        path.addCurve(
            to: CGPoint(x: center.x - w * 0.5, y: center.y - h * 0.1),
            control1: CGPoint(x: center.x - w * 0.3, y: center.y + h * 0.22),
            control2: CGPoint(x: center.x - w * 0.5, y: center.y + h * 0.1)
        )
        path.addArc(center: CGPoint(x: center.x - w * 0.25, y: center.y - h * 0.1),
                    radius: w * 0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: CGPoint(x: center.x + w * 0.25, y: center.y - h * 0.1),
                    radius: w * 0.25, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + h * 0.45),
            control1: CGPoint(x: center.x + w * 0.5, y: center.y + h * 0.1),
            control2: CGPoint(x: center.x + w * 0.3, y: center.y + h * 0.22)
        )
        path.closeSubpath()
        return path
    }

    /// Kaş gibi ince çizgiler için düz doğru.
    static func line(anchor: CGPoint, degrees: Double, length: CGFloat) -> Path {
        let rad = Angle.degrees(degrees).radians
        var path = Path()
        path.move(to: anchor)
        path.addLine(to: CGPoint(x: anchor.x + sin(rad) * length, y: anchor.y + cos(rad) * length))
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
        let shadowRect = CGRect(x: 0.5 * w - 0.21 * w * k, y: 0.975 * h - 0.0275 * h * k,
                                width: 0.42 * w * k, height: 0.055 * h * k)
        context.fill(
            Path(ellipseIn: shadowRect),
            with: .radialGradient(
                Gradient(colors: [.black.opacity(0.3 * Double(k)), .black.opacity(0)]),
                center: CGPoint(x: shadowRect.midX, y: shadowRect.midY),
                startRadius: 0,
                endRadius: shadowRect.width / 2
            )
        )

        // Gövde dönüşümleri (yükselme + çömelme + eğim), taban ortasına göre.
        context.translateBy(x: 0, y: frame.lift * h)
        context.translateBy(x: 0.5 * w, y: h)
        context.rotate(by: .degrees(frame.lean))
        context.scaleBy(x: 1 + frame.squash * 0.5, y: 1 - frame.squash)
        context.translateBy(x: -0.5 * w, y: -h)

        let shading = bodyShading(w: w, h: h)
        let inkShading = GraphicsContext.Shading.color(Self.ink)

        // Kuyruk ve ucundaki kalp — gövdenin arkasında.
        let tail = KenPath.tail(in: rect, curl: CGFloat(frame.tail))
        context.fill(tail.path, with: shading)
        context.fill(KenPath.heart(center: tail.tip, size: 0.16 * w), with: shading)

        // Kulaklar da arkada: tepeden dışarı taşsınlar.
        context.fill(KenPath.ear(in: rect, atX: 0.355, tilt: -1), with: shading)
        context.fill(KenPath.ear(in: rect, atX: 0.645, tilt: 1), with: shading)

        // Bacaklar ve sol kol gövdenin arkasında kalıyor.
        let legL = KenPath.limb(anchor: CGPoint(x: 0.38 * w, y: 0.76 * h), degrees: frame.legLeft,
                                length: 0.21 * h, rootWidth: 0.095 * w, tipWidth: 0.055 * w)
        let legR = KenPath.limb(anchor: CGPoint(x: 0.62 * w, y: 0.76 * h), degrees: frame.legRight,
                                length: 0.21 * h, rootWidth: 0.095 * w, tipWidth: 0.055 * w)
        let armL = KenPath.limb(anchor: CGPoint(x: 0.25 * w, y: 0.50 * h), degrees: frame.armLeft,
                                length: 0.19 * h, rootWidth: 0.085 * w, tipWidth: 0.05 * w)
        for limb in [legL, legR, armL] {
            context.fill(limb.path, with: shading)
            context.fill(KenPath.paw(at: limb.tip, direction: limb.direction, size: 0.10 * w), with: shading)
        }

        // Gövdenin arkasındaki sıcak parıltı. Eskiden .shadow ile yapılıyordu;
        // Canvas'ta gölge filtresi her karede blur demek olurdu, o yüzden aynı
        // görüntüyü radyal gradyanla veriyoruz — bedeli yok.
        context.fill(
            Path(ellipseIn: CGRect(x: 0.16 * w, y: 0.16 * h, width: 0.68 * w, height: 0.70 * h)),
            with: .radialGradient(
                Gradient(colors: [AppColors.primary.opacity(0.42), AppColors.primary.opacity(0)]),
                center: CGPoint(x: 0.5 * w, y: 0.53 * h),
                startRadius: 0.22 * w,
                endRadius: 0.36 * w
            )
        )
        context.fill(KenPath.body(in: rect), with: shading)

        // Açık renk göbek lekesi: hem hacim verir hem de Ken'i uygulamanın
        // pembesinden ayırır — eskiden zemine karışıyordu.
        context.fill(
            KenPath.ellipse(center: CGPoint(x: 0.5 * w, y: 0.63 * h), width: 0.42 * w, height: 0.30 * h),
            with: .color(Color(hex: "FFF1F6").opacity(0.28))
        )

        drawFace(in: &context, w: w, h: h, rect: rect, frame: frame, face: face, blink: blink, ink: inkShading)

        // Sağ kol en önde — gövdenin üstünden geçiyor.
        let armR = KenPath.limb(anchor: CGPoint(x: 0.75 * w, y: 0.50 * h), degrees: frame.armRight,
                                length: 0.19 * h, rootWidth: 0.085 * w, tipWidth: 0.05 * w)
        context.fill(armR.path, with: shading)
        context.fill(KenPath.paw(at: armR.tip, direction: armR.direction, size: 0.10 * w), with: shading)
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
        context.stroke(KenPath.line(anchor: CGPoint(x: 0.32 * w, y: 0.45 * h), degrees: 90 - face.browTilt, length: 0.12 * w), with: ink, style: browStyle)
        context.stroke(KenPath.line(anchor: CGPoint(x: 0.68 * w, y: 0.45 * h), degrees: -90 + face.browTilt, length: 0.12 * w), with: ink, style: browStyle)

        // Gözler: eskiden göz tümüyle küçültülüyordu, bu "gözü kısmak" değil
        // "gözü küçültmek" gibi duruyordu. Artık göz tam boyutta çiziliyor ve
        // ÜSTÜNE kapak iniyor — kısık, uykulu, şaşkın hepsi aynı stille çıkıyor.
        let closedAmount = min(1, face.eyeSquint + blink + (1 - frame.eyeOpen))
        let eyeSize = 0.075 * w
        let eyeY = 0.52 * h + frame.gazeY * 0.018 * h
        for eyeX in [0.415 * w, 0.605 * w] {
            let center = CGPoint(x: eyeX + frame.gazeX * 0.022 * w, y: eyeY)
            let eyeRect = CGRect(x: center.x - eyeSize / 2, y: center.y - eyeSize / 2,
                                 width: eyeSize, height: eyeSize)
            var eye = context
            eye.clip(to: Path(ellipseIn: eyeRect))
            // Kapağın altında kalan kısım görünür.
            let lidY = eyeRect.minY + eyeRect.height * closedAmount
            eye.fill(Path(CGRect(x: eyeRect.minX, y: lidY,
                                 width: eyeRect.width, height: eyeRect.height)), with: ink)
            if closedAmount < 0.45 {
                eye.fill(
                    KenPath.ellipse(
                        center: CGPoint(x: center.x - eyeSize * 0.2, y: center.y - eyeSize * 0.18),
                        width: eyeSize * 0.32, height: eyeSize * 0.32
                    ),
                    with: .color(.white.opacity(0.9))
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
