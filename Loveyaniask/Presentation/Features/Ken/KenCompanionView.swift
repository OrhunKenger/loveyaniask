//
//  KenCompanionView.swift
//  Loveyaniask
//
//  Ken'in tüm ekranların üstünde dolaşan görünmez-dokunma katmanı.
//  RootView'da TabView'ın üstüne, tek bir kez bindirilir. Karakter view'ı
//  hiç kaldırılıp yeniden kurulmaz (ve artık .id ile de sıfırlanmaz —
//  davranış geçişini kendi içinde harmanlıyor, bkz. KenMotion) — hep ekranda
//  durur, sadece opacity/pozisyon ile görünür/gizlenir.
//

import SwiftUI

struct KenCompanionView: View {
    let companion: KenCompanion

    @State private var activeBehavior: KenBehavior = .peek
    @State private var position: CGPoint = CGPoint(x: -100, y: -100)
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.6
    @State private var dangleX: CGFloat = 0.5

    @State private var tapLine: String?
    @State private var tapLineOpacity: Double = 0
    @State private var tapFadeTask: Task<Void, Never>?
    @State private var tapSquish: CGFloat = 1
    /// Davranış geçişinden hemen sonra söylenecek cümle (bkz. handleTap → uyanma).
    @State private var pendingLine: String?

    @State private var recentTapTimestamps: [Date] = []
    @State private var isAnnoyed = false
    @State private var annoyedResetTask: Task<Void, Never>?

    /// Dokunuş titreşimini tetiklemek için sayaç (her dokunuşta artar).
    @State private var tapTick = 0
    @State private var annoyedTick = 0

    private let size: CGFloat = 56

    private static let introText = "Merhaba, ben Ken 🐾\nArtık ailenizin yeni üyesiyim — evcil dijital dostunuzum diyebilirsiniz.\nSevincinizle sevinir, üzüntünüzle üzülürüm. Arada bir köşeden çıkarsam şaşırma 💗"

    private var daysTogether: Int {
        let start = UserDefaultsCoupleDataSource().loadStartDate()
        let calendar = Calendar.current
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: start),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0
        return max(0, elapsed)
    }

    /// Cümle seçimini besleyen o anki durum (saat, ruh hali, yaklaşan özel gün,
    /// dönüm günü, bulut satırları).
    private var lineContext: KenLineContext {
        KenLineContext(
            daysTogether: daysTogether,
            moodTone: companion.moodTone,
            hour: Calendar.current.component(.hour, from: Date()),
            upcoming: companion.upcomingSpecialDay,
            milestone: companion.celebratingDays,
            missedDays: companion.missedDays,
            cloudLines: companion.cloudLines
        )
    }

    private var currentSize: CGFloat {
        switch activeBehavior {
        case .introduce: size * 1.7
        case .celebrate: size * 1.15
        default: size
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if activeBehavior == .dangle {
                    Rectangle()
                        .fill(.white.opacity(0.16))
                        .frame(width: 1.5, height: 44)
                        .position(x: position.x, y: max(0, position.y - size * 0.75))
                        .opacity(opacity)
                }

                if activeBehavior == .snooze {
                    zzzLayer
                        .position(x: position.x + currentSize * 0.42, y: position.y - currentSize * 0.5)
                        .opacity(opacity)
                }

                if activeBehavior == .celebrate {
                    heartsLayer
                        .position(x: position.x, y: position.y - currentSize * 0.3)
                        .opacity(opacity)
                }

                if activeBehavior == .introduce {
                    speechBubble(Self.introText, width: 240)
                        .position(x: position.x, y: position.y - currentSize * 0.95)
                        .opacity(opacity)
                }

                if let tapLine {
                    speechBubble(tapLine, width: 200)
                        .position(x: position.x, y: position.y - currentSize * 0.95)
                        .opacity(tapLineOpacity)
                }

                KenCharacterView(
                    behavior: activeBehavior,
                    tone: companion.moodTone,
                    annoyed: isAnnoyed,
                    isVisible: opacity > 0.01
                )
                .frame(width: currentSize, height: currentSize * 1.15)
                .position(position)
                .opacity(opacity)
                .scaleEffect(scale * tapSquish)
                .allowsHitTesting(true)
                .onTapGesture { handleTap() }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            .onAppear {
                companion.startIdleLoop()
                if !companion.triggerIntroductionIfNeeded() {
                    companion.markAppOpenedIfNeeded(daysTogether: daysTogether)
                }
            }
            .onChange(of: companion.currentBehavior) { _, newValue in
                handleChange(newValue, screen: geo.size)
            }
        }
        .allowsHitTesting(false)
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: tapTick)
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.9), trigger: annoyedTick)
    }

    // MARK: - Süsler

    /// Uyurken başının üstünde yükselen "z"ler. Zamanın fonksiyonu olarak
    /// çiziliyor, böylece ayrı bir animasyon durumu tutmaya gerek kalmıyor.
    private var zzzLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    let u = ((t / 2.4) + Double(index) / 3).truncatingRemainder(dividingBy: 1)
                    Text("z")
                        .font(.system(size: 11 + CGFloat(index) * 3, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textSecondary.opacity(0.9 * (1 - u)))
                        .offset(x: CGFloat(u) * 16, y: -CGFloat(u) * 34)
                }
            }
        }
        .frame(width: 40, height: 40)
    }

    /// Kutlarken etrafa saçılan minik kalpler.
    private var heartsLayer: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    let seed = Double(index) * 0.37
                    let u = ((t / 1.7) + seed).truncatingRemainder(dividingBy: 1)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9 + CGFloat(index % 3) * 3))
                        .foregroundStyle(AppColors.primary.opacity(0.85 * (1 - u)))
                        .offset(
                            x: CGFloat(index - 3) * 9 + CGFloat(sin((u + seed) * .pi * 2) * 10),
                            y: -CGFloat(u) * 74
                        )
                        .scaleEffect(0.55 + 0.5 * CGFloat(1 - u))
                }
            }
        }
        .frame(width: 120, height: 100)
    }

    private func speechBubble(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.textPrimary)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: width)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(AppColors.glassStroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            )
    }

    // MARK: - Dokunma

    /// Ken'e dokununca: her zaman minik bir "tık" tepkisi + hafif titreşim, ama
    /// sadece bazen (yaklaşık %40) bir şey söyler — nadir olduğu için tatlı
    /// kalıyor. Uyurken dokunmak onu uyandırıp gerinmesine yol açar. 3 saniye
    /// içinde 4+ kez dokunulursa "gıcık oldum" tepkisine geçer (garanti).
    private func handleTap() {
        guard companion.currentBehavior != nil else { return }

        tapTick += 1
        withAnimation(.easeOut(duration: 0.12)) { tapSquish = 0.85 }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4).delay(0.12)) { tapSquish = 1 }

        let now = Date()
        recentTapTimestamps.append(now)
        recentTapTimestamps.removeAll { now.timeIntervalSince($0) > 3 }

        if recentTapTimestamps.count >= 4 {
            recentTapTimestamps.removeAll()
            triggerAnnoyed()
            return
        }

        // Uyurken dürtülünce uyanıp gerinir. Davranış değişimi balonu
        // temizlediği için cümleyi geçişten sonra söylesin diye bekletiyoruz.
        if activeBehavior == .snooze {
            pendingLine = KenLineSelector.line(from: KenTapLines.sleepy)
            companion.trigger(.stretch)
            return
        }

        guard Double.random(in: 0...1) < 0.4 else { return }
        speak(KenLineSelector.line(for: activeBehavior, context: lineContext))
    }

    private func triggerAnnoyed() {
        annoyedTick += 1
        isAnnoyed = true
        companion.keepAlive(extra: 2.6)
        speak(KenLineSelector.line(from: KenTapLines.annoyed), keepAlive: false)

        annoyedResetTask?.cancel()
        annoyedResetTask = Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { isAnnoyed = false }
        }
    }

    private func speak(_ line: String?, keepAlive: Bool = true) {
        guard let line else { return }
        tapLine = line
        if keepAlive { companion.keepAlive() }

        tapFadeTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) { tapLineOpacity = 1 }
        tapFadeTask = Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.35)) { tapLineOpacity = 0 }
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { tapLine = nil }
        }
    }

    // MARK: - Giriş / çıkış

    private func handleChange(_ behavior: KenBehavior?, screen: CGSize) {
        guard let behavior else {
            playExit(from: activeBehavior)
            return
        }

        if behavior == .dangle {
            dangleX = CGFloat.random(in: 0.3...0.7)
        }

        tapFadeTask?.cancel()
        tapLine = nil
        tapLineOpacity = 0
        annoyedResetTask?.cancel()
        isAnnoyed = false
        recentTapTimestamps.removeAll()

        activeBehavior = behavior
        position = startPosition(for: behavior, in: screen)
        opacity = 0
        scale = 0.6

        withAnimation(entrance(for: behavior)) {
            position = targetPosition(for: behavior, in: screen)
            opacity = 1
            scale = 1
        }

        if behavior == .wander {
            withAnimation(.linear(duration: max(behavior.displayDuration - 0.3, 0.3)).delay(0.3)) {
                position = CGPoint(x: screen.width + 40, y: screen.height * 0.55)
            }
        }

        // Kutlama ve özlem balonsuz eksik kalır; selam ise arada bir konuşsun.
        if let line = pendingLine {
            pendingLine = nil
            speak(line, keepAlive: false)
        } else if behavior.alwaysSpeaks, behavior != .introduce {
            speak(KenLineSelector.line(for: behavior, context: lineContext), keepAlive: false)
        } else if behavior == .greet, Double.random(in: 0...1) < 0.6 {
            speak(KenLineSelector.line(for: behavior, context: lineContext), keepAlive: false)
        }
    }

    /// Kayboluş da davranışa göre: kimi kenardan sıvışır, kimi yukarı çekilir,
    /// uyuyan ise ağır ağır solar.
    private func playExit(from behavior: KenBehavior) {
        switch behavior {
        case .introduce:
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 0
                position.x += 70
                position.y -= 50
            }
        case .peek:
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 0
                position.x += 70
            }
        case .dangle:
            withAnimation(.easeIn(duration: 0.55)) {
                opacity = 0
                position.y -= 90
            }
        case .snooze:
            withAnimation(.easeInOut(duration: 1.0)) { opacity = 0 }
        case .celebrate:
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 0
                position.y -= 60
                scale = 1.15
            }
        case .miss:
            withAnimation(.easeInOut(duration: 0.7)) {
                opacity = 0
                scale = 0.85
            }
        default:
            withAnimation(.easeIn(duration: 0.45)) { opacity = 0 }
        }
    }

    /// Canlı davranışlar yaylı, sakin olanlar yumuşak girsin.
    private func entrance(for behavior: KenBehavior) -> Animation {
        switch behavior {
        case .bounce, .celebrate, .greet: .spring(response: 0.45, dampingFraction: 0.6)
        case .snooze, .miss: .easeOut(duration: 0.9)
        default: .easeOut(duration: 0.5)
        }
    }

    private func targetPosition(for behavior: KenBehavior, in screen: CGSize) -> CGPoint {
        switch behavior {
        case .peek: CGPoint(x: screen.width - 46, y: screen.height - 150)
        case .dangle: CGPoint(x: screen.width * dangleX, y: 96)
        case .wander: CGPoint(x: screen.width * 0.5, y: screen.height * 0.55)
        case .sit: CGPoint(x: screen.width * 0.5, y: screen.height * 0.62)
        case .stretch: CGPoint(x: screen.width * 0.28, y: screen.height * 0.6)
        case .snooze: CGPoint(x: screen.width - 62, y: screen.height - 165)
        case .bounce: CGPoint(x: screen.width - 64, y: screen.height - 190)
        case .celebrate: CGPoint(x: screen.width * 0.5, y: screen.height * 0.44)
        case .greet: CGPoint(x: screen.width * 0.5, y: screen.height * 0.28)
        case .miss: CGPoint(x: screen.width * 0.34, y: screen.height * 0.58)
        case .introduce: CGPoint(x: screen.width * 0.5, y: screen.height * 0.46)
        }
    }

    private func startPosition(for behavior: KenBehavior, in screen: CGSize) -> CGPoint {
        switch behavior {
        case .peek: CGPoint(x: screen.width + 40, y: screen.height - 100)
        case .dangle: CGPoint(x: screen.width * dangleX, y: -60)
        case .wander: CGPoint(x: -40, y: screen.height * 0.55)
        case .celebrate: CGPoint(x: screen.width * 0.5, y: screen.height * 0.44 + 80)
        case .miss: CGPoint(x: -50, y: screen.height * 0.58)
        case .sit, .stretch, .snooze, .bounce, .greet: targetPosition(for: behavior, in: screen)
        case .introduce: CGPoint(x: -60, y: screen.height * 0.46)
        }
    }
}
