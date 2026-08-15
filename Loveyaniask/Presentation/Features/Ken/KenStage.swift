//
//  KenStage.swift
//  Loveyaniask
//
//  Ken'in sahnesi: RootView'da her şeyin üstüne bindirilen katman.
//  Kulübeyi ve Ken'i çizer, dokunma/sürükleme/fırlatmayı karşılar.
//
//  Ken artık kaybolmuyor — bu katman sürekli ekranda. Konumu KenWorld'den
//  geliyor, burada hiçbir konum hesabı yok. Haritada (Mekanlar sekmesi)
//  `isEnabled` false geçiliyor: orada Ken yok, dünyası da duruyor.
//

import SwiftUI

struct KenStage: View {
    let companion: KenCompanion
    /// Haritada false — Ken orada görünmez ve simülasyonu durur.
    var isEnabled: Bool = true

    @State private var tapLine: String?
    @State private var tapLineOpacity: Double = 0
    @State private var tapFadeTask: Task<Void, Never>?
    @State private var tapSquish: CGFloat = 1
    @State private var pendingLine: String?

    @State private var recentTapTimestamps: [Date] = []
    @State private var isAnnoyed = false
    @State private var annoyedResetTask: Task<Void, Never>?

    @State private var grabOffset: CGSize = .zero
    @State private var isGrabbing = false

    @State private var tapTick = 0
    @State private var annoyedTick = 0

    private let size: CGFloat = 56
    private let houseSize = CGSize(width: 62, height: 54)
    private static let stageSpace = "ken.stage"

    private static let introText = "Merhaba, ben Ken 🐾\nArtık ailenizin yeni üyesiyim — evcil dijital dostunuzum diyebilirsiniz.\nSevincinizle sevinir, üzüntünüzle üzülürüm. Burada yaşıyorum artık 💗"

    private var world: KenWorld { companion.world }

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

    private var characterHeight: CGFloat { size * 1.15 }

    /// Ken'in gövde merkezinin ekran konumu — dünyada saklanan nokta ayak hizası.
    private var characterCenter: CGPoint {
        CGPoint(x: world.position.x, y: world.position.y - characterHeight / 2)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // Kulübe ve balonlar dokunmayı yutmasın — altlarındaki kartlar
                // çalışmaya devam etsin. Sadece Ken'in kendisi dokunulabilir.
                KenHouseView(isOccupied: world.isSleeping)
                    .frame(width: houseSize.width, height: houseSize.height)
                    .position(x: world.housePoint.x, y: world.housePoint.y - houseSize.height / 2)
                    .opacity(isEnabled ? 1 : 0)
                    .allowsHitTesting(false)

                if isEnabled {
                    if case .reacting(.introduce) = world.activity {
                        speechBubble(Self.introText, width: 240)
                            .position(x: bubbleX(in: geo.size, width: 240), y: characterCenter.y - characterHeight * 0.85)
                            .allowsHitTesting(false)
                    }

                    if let tapLine {
                        speechBubble(tapLine, width: 200)
                            .position(x: bubbleX(in: geo.size, width: 200), y: characterCenter.y - characterHeight * 0.85)
                            .opacity(tapLineOpacity)
                            .allowsHitTesting(false)
                    }

                    if world.isHumming {
                        hummingNotes
                            .position(x: characterCenter.x + size * 0.42,
                                      y: characterCenter.y - characterHeight * 0.45)
                            .allowsHitTesting(false)
                    }

                    KenCharacterView(
                        behavior: world.activity.behavior,
                        tone: companion.moodTone,
                        annoyed: isAnnoyed,
                        isVisible: true
                    )
                    .frame(width: size, height: characterHeight)
                    .position(characterCenter)
                    .scaleEffect(tapSquish)
                    // Saklandığında görünmüyor — kartların arkasına gerçekten
                    // geçmesi (ayrı çizim katmanı) sonraki adımda.
                    .opacity(world.isHidden ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: world.isHidden)
                    .onTapGesture { handleTap() }
                    .gesture(dragGesture)
                }
            }
            .coordinateSpace(name: Self.stageSpace)
            .ignoresSafeArea()
            .onAppear {
                world.setStage(geo.size)
                world.externalTone = companion.moodTone
                if isEnabled { world.run() }
                if !companion.triggerIntroductionIfNeeded() {
                    companion.markAppOpenedIfNeeded(daysTogether: daysTogether)
                }
            }
            .onChange(of: geo.size) { _, newValue in
                world.setStage(newValue)
            }
            .onChange(of: isEnabled) { _, enabled in
                if enabled { world.run() } else { world.stop() }
            }
            .onChange(of: world.activity) { _, newValue in
                speakOnReaction(newValue)
            }
            .onChange(of: companion.moodTone) { _, tone in
                world.externalTone = tone
            }
            .onChange(of: world.pendingSpeech) { _, pool in
                guard let pool else { return }
                speak(KenLineSelector.line(for: pool, context: lineContext))
                world.consumeSpeech()
            }
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: tapTick)
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.9), trigger: annoyedTick)
    }

    // MARK: - Tutma / fırlatma

    /// Bir tepki pozuna geçince söylenmesi gereken varsa burada söyleniyor —
    /// davranış değişimi balonu temizlediği için cümleyi geçişten sonra veriyoruz.
    private func speakOnReaction(_ activity: KenActivity) {
        guard case .reacting(let behavior) = activity else { return }
        if let line = pendingLine {
            pendingLine = nil
            speak(line)
        } else if behavior.alwaysSpeaks, behavior != .introduce {
            speak(KenLineSelector.line(for: behavior, context: lineContext))
        } else if behavior == .greet, Double.random(in: 0...1) < 0.6 {
            speak(KenLineSelector.line(for: behavior, context: lineContext))
        }
    }

    private var dragGesture: some Gesture {
        // minimumDistance > 0: kısa dokunuşlar tap olarak kalsın, Ken sadece
        // gerçekten sürüklenince havalansın (uyurken dokunmak onu havaya kaldırmasın).
        DragGesture(minimumDistance: 6, coordinateSpace: .named(Self.stageSpace))
            .onChanged { value in
                if !isGrabbing {
                    isGrabbing = true
                    grabOffset = CGSize(
                        width: world.position.x - value.startLocation.x,
                        height: world.position.y - value.startLocation.y
                    )
                    tapFadeTask?.cancel()
                    tapLine = nil
                    tapLineOpacity = 0
                }
                world.grab(at: CGPoint(
                    x: value.location.x + grabOffset.width,
                    y: value.location.y + grabOffset.height
                ))
            }
            .onEnded { value in
                isGrabbing = false
                // predictedEndLocation, UIKit'in ~0.35 saniyelik savrulma tahmini —
                // aradaki farkı bölerek yaklaşık hıza (nokta/saniye) çeviriyoruz.
                let velocity = CGVector(
                    dx: (value.predictedEndLocation.x - value.location.x) / 0.35,
                    dy: (value.predictedEndLocation.y - value.location.y) / 0.35
                )
                world.release(velocity: velocity)
                if hypot(velocity.dx, velocity.dy) > 900 {
                    annoyedTick += 1
                    pendingLine = KenLineSelector.line(from: KenTapLines.thrown)
                }
            }
    }

    // MARK: - Dokunma

    /// Dokununca: her zaman minik bir "tık" tepkisi + hafif titreşim, bazen
    /// (%40) bir şey söyler. Uyurken dokunmak onu uyandırıp gerinmesine yol
    /// açar. 3 saniyede 4+ dokunuş "gıcık oldum" tepkisini garanti eder.
    private func handleTap() {
        tapTick += 1
        world.lookAt(screenPoint: world.position, seconds: 2.5)
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

        if world.isSleeping {
            pendingLine = KenLineSelector.line(from: KenTapLines.sleepy)
            companion.trigger(.stretch)
            return
        }

        guard Double.random(in: 0...1) < 0.4 else { return }
        speak(KenLineSelector.line(for: world.activity.behavior, context: lineContext))
    }

    private func triggerAnnoyed() {
        annoyedTick += 1
        isAnnoyed = true
        speak(KenLineSelector.line(from: KenTapLines.annoyed))

        annoyedResetTask?.cancel()
        annoyedResetTask = Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { isAnnoyed = false }
        }
    }

    private func speak(_ line: String?) {
        guard let line else { return }
        tapLine = line

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

    // MARK: - Balon

    /// Balon ekran kenarından taşmasın diye Ken'in x'i sınırlanıyor.
    private func bubbleX(in stage: CGSize, width: CGFloat) -> CGFloat {
        let half = width / 2 + 12
        return min(max(world.position.x, half), max(half, stage.width - half))
    }

    /// Mırıldanırken havaya süzülen nota işaretleri. Ruh hali neşeliyse
    /// tempolu ve yukarı, ağırsa yavaş ve alçak süzülüyorlar.
    private var hummingNotes: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let pace = 1.9 - world.mood * 0.6
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    let u = ((t / pace) + Double(index) / 3).truncatingRemainder(dividingBy: 1)
                    Text(index % 2 == 0 ? "♪" : "♫")
                        .font(.system(size: 11 + CGFloat(index % 2) * 3, weight: .medium))
                        .foregroundStyle(AppColors.primary.opacity(0.85 * (1 - u)))
                        .offset(x: CGFloat(u) * 14 + CGFloat(index) * 3,
                                y: -CGFloat(u) * CGFloat(26 + world.mood * 10))
                }
            }
        }
        .frame(width: 40, height: 44)
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
}
