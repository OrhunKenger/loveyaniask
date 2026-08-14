//
//  KenCompanionView.swift
//  Loveyaniask
//
//  Ken'in tüm ekranların üstünde dolaşan görünmez-dokunma katmanı.
//  RootView'da TabView'ın üstüne, tek bir kez bindirilir. Karakter view'ı
//  hiç kaldırılıp yeniden kurulmaz (structural remove animasyonu bozar) —
//  onun yerine hep ekranda durur, sadece opacity/pozisyon ile görünür/gizlenir.
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
    @State private var lastTapLine: String?

    @State private var recentTapTimestamps: [Date] = []
    @State private var isAnnoyed = false
    @State private var annoyedResetTask: Task<Void, Never>?

    private let size: CGFloat = 56

    private static let introText = "Merhaba, ben Ken 🐾\nArtık ailenizin yeni üyesiyim — evcil dijital dostunuzum diyebilirsiniz.\nSevincinizle sevinir, üzüntünüzle üzülürüm. Arada bir köşeden çıkarsam şaşırma 💗"

    /// Dokunma balonu için üç kaynağın birleşimi: sabit kategorili havuz
    /// (KenTapLines), gün-sayacı bazlı dinamik satırlar, ve bulut routine'inin
    /// o an için ürettiği taze satırlar (companion.cloudLines).
    private var tapLinePool: [String] {
        KenTapLines.all + KenTapLines.dynamic(daysTogether: daysTogether) + companion.cloudLines
    }

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

    private var currentSize: CGFloat {
        activeBehavior == .introduce ? size * 1.7 : size
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

                KenCharacterView(behavior: activeBehavior, tone: companion.moodTone, annoyed: isAnnoyed)
                    .id(activeBehavior)
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
                    companion.markAppOpenedIfNeeded()
                }
            }
            .onChange(of: companion.currentBehavior) { _, newValue in
                handleChange(newValue, screen: geo.size)
            }
        }
        .allowsHitTesting(false)
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

    /// Ken'e dokununca: her zaman minik bir "tık" tepkisi, ama sadece bazen
    /// (yaklaşık %40) sabit cümle havuzundan bir şey söyler — sürekli
    /// konuşmuyor, nadiren ve sürpriz olduğu için tatlı kalıyor. 3 saniye
    /// içinde 4+ kez dokunulursa "gıcık oldum" tepkisine geçer (garanti, ifade değişir).
    private func handleTap() {
        guard companion.currentBehavior != nil else { return }

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

        guard Double.random(in: 0...1) < 0.4 else { return }
        showLine(from: tapLinePool)
    }

    private func triggerAnnoyed() {
        withAnimation(.easeInOut(duration: 0.2)) { isAnnoyed = true }
        companion.keepAlive(extra: 2.6)
        showLine(from: KenTapLines.annoyed, guaranteed: true)

        annoyedResetTask?.cancel()
        annoyedResetTask = Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) { isAnnoyed = false }
            }
        }
    }

    private func showLine(from pool: [String], guaranteed: Bool = false) {
        var candidates = pool
        if let lastTapLine, candidates.count > 1 {
            candidates.removeAll { $0 == lastTapLine }
        }
        guard let line = candidates.randomElement() else { return }
        lastTapLine = line
        tapLine = line
        if !guaranteed { companion.keepAlive() }

        tapFadeTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) { tapLineOpacity = 1 }
        tapFadeTask = Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.35)) { tapLineOpacity = 0 }
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { tapLine = nil }
        }
    }

    private func handleChange(_ behavior: KenBehavior?, screen: CGSize) {
        guard let behavior else {
            if activeBehavior == .introduce {
                // Tanıtım bitince sessizce solmak yerine yukarı-sağa doğru uçup kaçar.
                withAnimation(.easeIn(duration: 0.6)) {
                    opacity = 0
                    position.x += 70
                    position.y -= 50
                }
            } else {
                withAnimation(.easeIn(duration: 0.45)) { opacity = 0 }
            }
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

        withAnimation(.easeOut(duration: 0.5)) {
            position = targetPosition(for: behavior, in: screen)
            opacity = 1
            scale = 1
        }

        if behavior == .wander {
            withAnimation(.linear(duration: max(behavior.displayDuration - 0.3, 0.3)).delay(0.3)) {
                position = CGPoint(x: screen.width + 40, y: screen.height * 0.55)
            }
        }
    }

    private func targetPosition(for behavior: KenBehavior, in screen: CGSize) -> CGPoint {
        switch behavior {
        case .peek: CGPoint(x: screen.width - 46, y: screen.height - 150)
        case .dangle: CGPoint(x: screen.width * dangleX, y: 96)
        case .wander: CGPoint(x: screen.width * 0.5, y: screen.height * 0.55)
        case .sit: CGPoint(x: screen.width * 0.5, y: screen.height * 0.62)
        case .bounce: CGPoint(x: screen.width - 64, y: screen.height - 190)
        case .greet: CGPoint(x: screen.width * 0.5, y: screen.height * 0.28)
        case .introduce: CGPoint(x: screen.width * 0.5, y: screen.height * 0.46)
        }
    }

    private func startPosition(for behavior: KenBehavior, in screen: CGSize) -> CGPoint {
        switch behavior {
        case .peek: CGPoint(x: screen.width + 40, y: screen.height - 100)
        case .dangle: CGPoint(x: screen.width * dangleX, y: -60)
        case .wander: CGPoint(x: -40, y: screen.height * 0.55)
        case .sit, .bounce, .greet: targetPosition(for: behavior, in: screen)
        case .introduce: CGPoint(x: -60, y: screen.height * 0.46)
        }
    }
}
