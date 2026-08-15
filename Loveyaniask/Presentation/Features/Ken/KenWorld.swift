//
//  KenWorld.swift
//  Loveyaniask
//
//  Ken'in dünyası: nerede olduğu, ne yaptığı, nasıl hareket ettiği.
//  Ekrandan bağımsız — görünümler sadece bu durumu çizer.
//
//  Eskiden Ken tetiklenip süresi dolunca kaybolan bir görsel efektti
//  (trigger → displayDuration → nil). Artık kalıcı bir sakin: konumu var,
//  fizikle hareket ediyor, tutulup atılabiliyor, konumu diske yazılıyor.
//  Karar mekanizması şimdilik basit (dinlen / yürü / gece uyu); ihtiyaç
//  sistemi bir sonraki fazda buraya gelecek.
//
//  Koordinat: `position` Ken'in AYAK noktası (gövdesinin alt-ortası), ekran
//  noktası cinsinden. Fizik böyle çok daha basit — zemin tek bir y değeri.
//

import Foundation
import Observation
import CoreGraphics

/// Ken'in o an ne yaptığı. Çizim tarafı bunu bir poza çeviriyor (`behavior`).
enum KenActivity: Equatable {
    /// Oturuyor, nefes alıyor.
    case resting
    /// Bir hedefe doğru yürüyor.
    case walking
    /// Kulübesinde uyuyor.
    case sleeping
    /// Parmakla tutulmuş, havada.
    case held
    /// Fırlatıldı ya da düşüyor.
    case airborne
    /// Sert düşüşten sonra sersemlemiş.
    case dizzy
    /// Kısa süreli tepki pozu (kutlama, selam, özlem...).
    case reacting(KenBehavior)

    var behavior: KenBehavior {
        switch self {
        case .resting: .sit
        case .walking: .wander
        case .sleeping: .snooze
        case .held, .airborne: .held
        case .dizzy: .dizzy
        case .reacting(let behavior): behavior
        }
    }
}

@Observable
final class KenWorld {
    private(set) var position = CGPoint(x: 120, y: 400)
    private(set) var velocity = CGVector.zero
    private(set) var activity: KenActivity = .resting
    /// Yürüdüğü yön: -1 sola, 1 sağa. (Çizimde ileride yansıtma için.)
    private(set) var facing: CGFloat = 1

    /// Sahne boyutu bilinmeden fizik çalışmaz; ilk çizimde set ediliyor.
    private(set) var stage: CGSize = .zero

    private var lastTick: Date?
    private var loop: Task<Void, Never>?
    private var activityUntil: Date?
    private var nextDecisionAt = Date()
    private var walkTargetX: CGFloat?
    private var goingHome = false
    private var hardLandingPending = false
    private var pauseCount = 0
    private var lastSaveAt = Date.distantPast

    private enum K {
        static let gravity: CGFloat = 2400
        /// Zeminin ekranın altından yüksekliği — tab bar'ın üstünde dursun diye.
        static let floorInset: CGFloat = 78
        static let ceiling: CGFloat = 110
        static let sideMargin: CGFloat = 28
        static let floorBounce: CGFloat = 0.42
        static let wallBounce: CGFloat = 0.55
        static let walkSpeed: CGFloat = 54
        /// Bu hızın üstünde yere çakılırsa sersemler.
        static let hardLanding: CGFloat = 900
        static let tickInterval: UInt64 = 33_000_000
    }

    private static let posXKey = "ken.world.x"
    private static let posYKey = "ken.world.y"

    // MARK: - Sahne ve döngü

    /// Ekran boyutu değiştiğinde (ilk çizim, döndürme) çağrılır.
    func setStage(_ size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let isFirst = stage == .zero
        stage = size
        if isFirst {
            position = restoredPosition(in: size)
        }
        clampToStage()
    }

    /// Ken görünürken çalışır (haritada durur — orada Ken yok).
    func run() {
        guard loop == nil else { return }
        lastTick = nil
        loop = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: K.tickInterval)
                guard let self else { return }
                self.tick(now: Date())
            }
        }
    }

    func stop() {
        loop?.cancel()
        loop = nil
        save()
    }

    /// Yazı yazarken vb. Ken dolaşmayı bıraksın — sayaç tabanlı, iç içe güvenli.
    func pause() { pauseCount += 1 }
    func resume() { pauseCount = max(0, pauseCount - 1) }

    // MARK: - Etkileşim

    /// Parmakla tutuldu / sürükleniyor. `point` Ken'in olması gereken ayak noktası.
    func grab(at point: CGPoint) {
        if activity != .held {
            activity = .held
            activityUntil = nil
            walkTargetX = nil
            goingHome = false
        }
        velocity = .zero
        position = point
        clampToStage()
    }

    /// Bırakıldı. `velocity` parmağın bıraktığı andaki hızı (nokta/saniye).
    func release(velocity v: CGVector) {
        let speed = hypot(v.dx, v.dy)
        velocity = CGVector(dx: v.dx.clamped(to: -3000...3000), dy: v.dy.clamped(to: -3000...3000))
        activity = .airborne
        activityUntil = nil
        // Sadece gerçekten fırlatılırsa sersemlesin — usulca bırakınca değil.
        hardLandingPending = speed > K.hardLanding
        if v.dx != 0 { facing = v.dx > 0 ? 1 : -1 }
    }

    /// Kısa süreli bir tepki pozu oynat (olay tetikleri buradan geçiyor).
    func react(_ behavior: KenBehavior, seconds: TimeInterval = 2.6) {
        guard activity != .held else { return }
        activity = .reacting(behavior)
        activityUntil = Date().addingTimeInterval(seconds)
        walkTargetX = nil
        velocity.dx = 0
    }

    /// Sadece boştaysa tepki ver — art arda gelen küçük olaylarda Ken'in
    /// yanıp sönen bir bildirime dönüşmemesi için.
    func reactIfResting(_ behavior: KenBehavior, seconds: TimeInterval = 2.6) {
        guard activity == .resting || activity == .walking else { return }
        react(behavior, seconds: seconds)
    }

    var isSleeping: Bool { activity == .sleeping }

    // MARK: - Simülasyon

    private func tick(now: Date) {
        guard stage != .zero else { return }
        let elapsed = now.timeIntervalSince(lastTick ?? now)
        lastTick = now
        // Uygulama arka plandan dönünce dev bir dt ile ışınlanmasın diye tavan.
        let dt = CGFloat(min(max(elapsed, 0), 1.0 / 15))
        guard dt > 0 else { return }

        if activity != .held {
            integrate(dt)
            updateActivity(now: now)
        }
        saveIfNeeded(now)
    }

    private func integrate(_ dt: CGFloat) {
        let floorY = stage.height - K.floorInset
        let onGround = position.y >= floorY - 0.5 && abs(velocity.dy) < 20

        if onGround {
            if activity == .walking, let target = walkTargetX {
                if abs(target - position.x) < 4 {
                    walkTargetX = nil
                    velocity.dx = 0
                } else {
                    let direction: CGFloat = target > position.x ? 1 : -1
                    velocity.dx = direction * K.walkSpeed
                    facing = direction
                }
            } else {
                velocity.dx -= velocity.dx * min(1, 6 * dt)
            }
        } else {
            velocity.dy += K.gravity * dt
        }

        position.x += velocity.dx * dt
        position.y += velocity.dy * dt

        let impact = velocity.dy

        if position.y > floorY {
            position.y = floorY
            if impact > K.hardLanding { hardLandingPending = true }
            if impact > 60 {
                velocity.dy = -impact * K.floorBounce
                velocity.dx *= 0.7
            } else {
                velocity.dy = 0
            }
        }
        if position.y < K.ceiling {
            position.y = K.ceiling
            velocity.dy = abs(velocity.dy) * K.floorBounce
        }

        let minX = K.sideMargin
        let maxX = max(minX, stage.width - K.sideMargin)
        if position.x < minX {
            position.x = minX
            velocity.dx = abs(velocity.dx) * K.wallBounce
            facing = 1
        }
        if position.x > maxX {
            position.x = maxX
            velocity.dx = -abs(velocity.dx) * K.wallBounce
            facing = -1
        }
    }

    private func updateActivity(now: Date) {
        let floorY = stage.height - K.floorInset
        let settled = position.y >= floorY - 0.5 && abs(velocity.dy) < 20 && abs(velocity.dx) < 20

        if hardLandingPending, settled {
            hardLandingPending = false
            activity = .dizzy
            activityUntil = now.addingTimeInterval(1.7)
            return
        }

        if let until = activityUntil {
            guard now >= until else { return }
            activityUntil = nil
            // Sersemlemenin ardından hakkı olan tepki: doğrulup söylenmek.
            if activity == .dizzy {
                activity = .reacting(.grumble)
                activityUntil = now.addingTimeInterval(2.4)
                return
            }
            activity = .resting
            scheduleNextDecision(now)
            return
        }

        switch activity {
        case .airborne:
            if settled {
                activity = .resting
                scheduleNextDecision(now)
            }
        case .walking:
            if walkTargetX == nil {
                if goingHome {
                    goingHome = false
                    activity = .sleeping
                    scheduleNextDecision(now, minimum: 40, maximum: 90)
                } else {
                    activity = .resting
                    scheduleNextDecision(now)
                }
            }
        case .resting, .sleeping:
            if now >= nextDecisionAt { decide(now) }
        default:
            break
        }
    }

    /// Faz A'nın basit gündemi: çoğunlukla dinlen, arada yürü, gece eve git.
    /// İhtiyaç sayaçları (uyku/can sıkıntısı/yakınlık/merak) bir sonraki fazda.
    private func decide(_ now: Date) {
        guard pauseCount == 0 else {
            scheduleNextDecision(now)
            return
        }
        let hour = Calendar.current.component(.hour, from: now)
        let isNight = hour >= 23 || hour < 6

        if isNight, activity != .sleeping, Double.random(in: 0...1) < 0.7 {
            goingHome = true
            walkTargetX = homeX
            activity = .walking
            return
        }
        if activity == .sleeping {
            if isNight {
                scheduleNextDecision(now, minimum: 40, maximum: 90)
                return
            }
            activity = .resting
            scheduleNextDecision(now, minimum: 3, maximum: 8)
            return
        }
        if Double.random(in: 0...1) < 0.6 {
            goingHome = false
            walkTargetX = CGFloat.random(in: K.sideMargin...max(K.sideMargin, stage.width - K.sideMargin))
            activity = .walking
        } else {
            activity = .resting
            scheduleNextDecision(now)
        }
    }

    private func scheduleNextDecision(_ now: Date, minimum: TimeInterval = 5, maximum: TimeInterval = 16) {
        nextDecisionAt = now.addingTimeInterval(.random(in: minimum...maximum))
    }

    // MARK: - Kulübe

    /// Kulübenin ayak noktası — sağ altta, zeminin üstünde.
    var housePoint: CGPoint {
        CGPoint(x: max(K.sideMargin, stage.width - 52), y: stage.height - K.floorInset)
    }

    private var homeX: CGFloat { housePoint.x - 6 }

    /// Zemin çizgisi — kulübe ve Ken aynı hatta bassın diye görünüm tarafı da kullanıyor.
    var floorY: CGFloat { stage.height - K.floorInset }

    // MARK: - Kalıcılık

    private func clampToStage() {
        guard stage != .zero else { return }
        position.x = position.x.clamped(to: K.sideMargin...max(K.sideMargin, stage.width - K.sideMargin))
        position.y = position.y.clamped(to: K.ceiling...max(K.ceiling, stage.height - K.floorInset))
    }

    private func restoredPosition(in size: CGSize) -> CGPoint {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: Self.posXKey) != nil else {
            return CGPoint(x: size.width * 0.5, y: size.height - K.floorInset)
        }
        // Oran olarak saklanıyor ki farklı ekran boyutunda da anlamlı olsun.
        return CGPoint(
            x: CGFloat(defaults.double(forKey: Self.posXKey)) * size.width,
            y: CGFloat(defaults.double(forKey: Self.posYKey)) * size.height
        )
    }

    private func saveIfNeeded(_ now: Date) {
        guard now.timeIntervalSince(lastSaveAt) > 5 else { return }
        lastSaveAt = now
        save()
    }

    private func save() {
        guard stage.width > 0, stage.height > 0 else { return }
        let defaults = UserDefaults.standard
        defaults.set(Double(position.x / stage.width), forKey: Self.posXKey)
        defaults.set(Double(position.y / stage.height), forKey: Self.posYKey)
    }
}

private extension CGFloat {
    /// Swift.min/Swift.max olarak nitelenmeli: CGFloat uzantısının içinde
    /// niteliksiz `max`, global fonksiyon yerine CGFloat'ın statik üyesine çözülüyor.
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
