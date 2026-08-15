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

    /// Bakış yönü, -1...1. Sahneler ve kullanıcı etkileşimi birlikte belirliyor.
    private(set) var gaze = CGPoint(x: 0, y: 0)
    /// Kartların arkasına saklandı mı.
    private(set) var isHidden = false
    /// Mırıldanıyor mu — görünüm minik nota işaretleri çıkarıyor.
    private(set) var isHumming = false
    /// Söylemek istediği şeyin havuzu; görünüm alıp cümleye çeviriyor.
    private(set) var pendingSpeech: KenLinePool?
    /// Ken'in kendi iç havası: -1 (ağır) ... 1 (neşeli). Ne yapacağını değil,
    /// NASIL yapacağını belirliyor — hareketin genliği, mırıltının tonu.
    private(set) var mood: Double = 0.35

    /// Sahne boyutu bilinmeden fizik çalışmaz; ilk çizimde set ediliyor.
    private(set) var stage: CGSize = .zero

    private var lastTick: Date?
    private var loop: Task<Void, Never>?
    private var activityUntil: Date?
    private var nextDecisionAt = Date()
    private var walkTargetX: CGFloat?
    private var hardLandingPending = false
    private var pauseCount = 0
    private var lastSaveAt = Date.distantPast

    // MARK: Beyin
    /// Dürtüler 0...1 arası dolar; en baskın olan hangi sahnenin oynayacağını
    /// belirler. Rastgele seçim yerine sebepli davranış — "bugün niye hep
    /// kulübede" sorusunun bir cevabı olsun diye.
    private var drives: [KenDrive: Double] = [.sleep: 0.1, .boredom: 0.3, .closeness: 0.2, .curiosity: 0.1]
    private var scene: KenScene?
    private var beatIndex = 0
    private var beatUntil: Date?
    private var gazeTarget = CGPoint(x: 0, y: 0)
    private var gazeHoldUntil: Date?
    private var moodDriftAt = Date()
    private var isRunning = false
    private var lastSceneDrive: KenDrive?
    /// Dışarıdan beslenen ton (sizin ruh haliniz) — Ken'in havasını etkiler.
    var externalTone: Double?

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
            // Elindeyken sahne oynamaz — bıraktığında yenisi başlar.
            scene = nil
            isHidden = false
            isHumming = false
            isRunning = false
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
        // Olay tepkisi sahneyi keser — Ken ne yapıyorsa bırakıp size döner.
        scene = nil
        isHidden = false
        isHumming = false
        isRunning = false
        activity = .reacting(behavior)
        activityUntil = Date().addingTimeInterval(seconds)
        walkTargetX = nil
        velocity.dx = 0
        drives[.curiosity] = 0
    }

    /// Sadece boştaysa tepki ver — art arda gelen küçük olaylarda Ken'in
    /// yanıp sönen bir bildirime dönüşmemesi için.
    func reactIfResting(_ behavior: KenBehavior, seconds: TimeInterval = 2.6) {
        guard activity == .resting || activity == .walking || scene != nil else { return }
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

        updateDrives(dt, now: now)
        updateGaze(dt, now: now)
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
                    // Neşeliyken biraz daha çevik yürüyor; koşarken iki katı.
                    let speed = K.walkSpeed * CGFloat(0.85 + mood * 0.25) * (isRunning ? 2.1 : 1)
                    velocity.dx = direction * speed
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

        // Sahne oynuyorsa adımları ilerlet.
        if scene != nil {
            let walkDone = activity == .walking && walkTargetX == nil
            let timeUp = beatUntil.map { now >= $0 } ?? false
            if walkDone || timeUp { advanceBeat(now) }
            return
        }

        switch activity {
        case .airborne:
            if settled {
                activity = .resting
                scheduleNextDecision(now)
            }
        case .resting, .sleeping, .walking:
            if now >= nextDecisionAt { decide(now) }
        default:
            break
        }
    }

    /// Sahne seçimi: dürtüler doldukça baskın olan kategori öne çıkıyor.
    /// Rastgele değil sebepli — aynı sahne farklı ruh hâlinde farklı oynanıyor.
    private func decide(_ now: Date) {
        guard pauseCount == 0 else {
            scheduleNextDecision(now)
            return
        }
        let hour = Calendar.current.component(.hour, from: now)
        let isNight = hour >= 23 || hour < 6

        var candidates: [(KenScene, Double)] = []
        for candidate in KenScenes.all {
            if candidate.nightOnly, !isNight { continue }
            if candidate.dayOnly, isNight { continue }
            let drive = drives[candidate.drive] ?? 0
            // Dürtü ne kadar doluysa o kategorinin sahneleri o kadar olası.
            candidates.append((candidate, candidate.weight * (0.15 + drive * 2)))
        }
        guard let picked = Self.weightedPick(candidates) else {
            scheduleNextDecision(now)
            return
        }
        start(scene: picked, now: now)
    }

    private func start(scene picked: KenScene, now: Date) {
        scene = picked
        lastSceneDrive = picked.drive
        beatIndex = 0
        beatUntil = nil
        beginCurrentBeat(now)
    }

    /// Sahnenin o anki adımını uygular. Adım bitince bir sonrakine geçilir.
    private func beginCurrentBeat(_ now: Date) {
        guard let scene, beatIndex < scene.beats.count else {
            finishScene(now)
            return
        }
        switch scene.beats[beatIndex] {
        case .walk(let anchor):
            walkTargetX = position(of: anchor).x
            activity = .walking
            beatUntil = now.addingTimeInterval(12)   // emniyet: takılırsa geç

        case .run(let anchor):
            walkTargetX = position(of: anchor).x
            activity = .walking
            isRunning = true
            beatUntil = now.addingTimeInterval(8)

        case .pose(let behavior, let seconds):
            activity = .reacting(behavior)
            beatUntil = now.addingTimeInterval(seconds * moodPace)

        case .wait(let seconds):
            activity = .resting
            beatUntil = now.addingTimeInterval(seconds * moodPace)

        case .say(let pool):
            pendingSpeech = pool
            beatUntil = now   // anında sonraki adıma

        case .hum(let seconds):
            isHumming = true
            beatUntil = now.addingTimeInterval(seconds)

        case .look(let x, let y, let seconds):
            gazeTarget = CGPoint(x: x, y: y)
            gazeHoldUntil = now.addingTimeInterval(seconds)
            beatUntil = now.addingTimeInterval(seconds)

        case .hide(let seconds):
            isHidden = true
            activity = .resting
            beatUntil = now.addingTimeInterval(seconds)

        case .peekOut(let seconds):
            isHidden = false
            activity = .reacting(.peek)
            beatUntil = now.addingTimeInterval(seconds)

        case .leaveTrace, .cleanTrace:
            // İzler görünüm katmanının işi; motor sadece haber veriyor.
            beatUntil = now
        }
    }

    private func advanceBeat(_ now: Date) {
        isHumming = false
        isRunning = false
        beatIndex += 1
        beginCurrentBeat(now)
    }

    private func finishScene(_ now: Date) {
        scene = nil
        isHidden = false
        isHumming = false
        isRunning = false
        walkTargetX = nil
        activity = .resting
        satisfyDrive(of: nil)
        scheduleNextDecision(now, minimum: 1.5, maximum: 5)
    }

    /// Sahne bitince ilgili dürtü boşalıyor.
    private func satisfyDrive(of drive: KenDrive?) {
        guard let drive = drive ?? lastSceneDrive else { return }
        drives[drive] = max(0, (drives[drive] ?? 0) - 0.75)
        lastSceneDrive = nil
    }

    /// Dürtüleri zamanla doldurur ve Ken'in havasını yavaşça sürükler.
    private func updateDrives(_ dt: CGFloat, now: Date) {
        let hour = Calendar.current.component(.hour, from: now)
        let isNight = hour >= 23 || hour < 6
        let seconds = Double(dt)

        drives[.sleep, default: 0] += seconds * (isNight ? 0.012 : 0.002)
        drives[.boredom, default: 0] += seconds * 0.010
        drives[.closeness, default: 0] += seconds * 0.006
        drives[.curiosity, default: 0] += seconds * 0.001
        for key in drives.keys {
            drives[key] = Swift.min(1, drives[key] ?? 0)
        }

        // Ruh hali: sizin tonunuz + kendi bağımsız dalgalanması.
        guard now.timeIntervalSince(moodDriftAt) > 20 else { return }
        moodDriftAt = now
        // externalTone 0 (sıcak/iyi) ... 1 (soğuk/zor) geliyor; mood ters yönde.
        let fromYou = externalTone.map { 1 - $0 * 1.6 } ?? mood
        let ownDrift = Double.random(in: -0.12...0.12)
        mood = Swift.max(-1, Swift.min(1, mood * 0.75 + fromYou * 0.25 + ownDrift * 0.35))
    }

    /// Neşeliyken tempolu, ağırken uzun — aynı sahne iki farklı Ken.
    private var moodPace: Double {
        1.25 - mood * 0.35
    }

    private func scheduleNextDecision(_ now: Date, minimum: TimeInterval = 5, maximum: TimeInterval = 16) {
        nextDecisionAt = now.addingTimeInterval(.random(in: minimum...maximum))
    }

    // MARK: - Çapalar ve bakış

    /// Çapanın ekrandaki karşılığı. Ken artık "rastgele bir x"e değil,
    /// anlamı olan yerlere gidiyor.
    func position(of anchor: KenAnchor) -> CGPoint {
        let floor = floorY
        switch anchor {
        case .home: return housePoint
        case .ceiling: return CGPoint(x: stage.width * CGFloat.random(in: 0.3...0.7), y: K.ceiling)
        case .tabBar: return CGPoint(x: stage.width * CGFloat.random(in: 0.25...0.75), y: floor)
        case .leftEdge: return CGPoint(x: K.sideMargin + 6, y: floor)
        case .rightEdge: return CGPoint(x: Swift.max(K.sideMargin, stage.width - K.sideMargin - 6), y: floor)
        case .center: return CGPoint(x: stage.width * 0.5, y: floor)
        case .wherever:
            return CGPoint(x: CGFloat.random(in: K.sideMargin...Swift.max(K.sideMargin, stage.width - K.sideMargin)), y: floor)
        }
    }

    /// Bakış yumuşak şekilde hedefe yaklaşıyor — ani sıçrama cansız durur.
    private func updateGaze(_ dt: CGFloat, now: Date) {
        if let hold = gazeHoldUntil, now >= hold {
            gazeHoldUntil = nil
            gazeTarget = .zero
        }
        let k = Swift.min(1, Double(dt) * 4)
        gaze.x += (gazeTarget.x - gaze.x) * CGFloat(k)
        gaze.y += (gazeTarget.y - gaze.y) * CGFloat(k)
    }

    /// Kullanıcı bir şey yaptı — Ken ona baksın. "İlgilenmek" sana değil,
    /// SENİN YAPTIĞIN ŞEYE bakmak demek; hep öne bakması onu maskot yapıyordu.
    func lookAt(screenPoint: CGPoint, seconds: TimeInterval = 2.5) {
        guard stage.width > 0 else { return }
        let dx = (screenPoint.x - position.x) / (stage.width * 0.5)
        let dy = (screenPoint.y - position.y) / (stage.height * 0.5)
        gazeTarget = CGPoint(x: Swift.max(-1, Swift.min(1, dx)), y: Swift.max(-1, Swift.min(1, dy)))
        gazeHoldUntil = Date().addingTimeInterval(seconds)
    }

    /// Görünüm cümleyi aldıktan sonra çağırıyor.
    func consumeSpeech() {
        pendingSpeech = nil
    }

    // MARK: - Kulübe

    /// Kulübenin ayak noktası — sağ altta, zeminin üstünde.
    var housePoint: CGPoint {
        CGPoint(x: max(K.sideMargin, stage.width - 52), y: stage.height - K.floorInset)
    }


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
