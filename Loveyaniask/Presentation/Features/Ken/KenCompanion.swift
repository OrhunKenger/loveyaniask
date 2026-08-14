//
//  KenCompanion.swift
//  Loveyaniask
//
//  Ken'in "varlık motoru": ekranlarda kendiliğinden dolaşmasını yöneten
//  paylaşılan kontrolcü. Tek bir örneği AppDependencies'te oluşturulup hem
//  KenCompanionView'a (çizim) hem de ilgili ViewModel'lere (olay tetikleri)
//  enjekte edilir.
//

import Foundation
import Observation

/// Ken'in sergileyebileceği davranışlar. `peek/dangle/wander/sit` boşta
/// kendiliğinden rastgele seçilir; `bounce/greet` sadece belirli olaylarla
/// (puanlama, paylaşım, günün ilk açılışı) tetiklenir.
enum KenBehavior: CaseIterable, Hashable {
    case peek
    case dangle
    case wander
    case sit
    case bounce
    case greet
    /// Sadece ilk girişte, bir kere: büyükçe belirir, kendini tanıtan bir
    /// konuşma balonu açar, sonra uçup gider. Bkz. KenCompanion.triggerIntroductionIfNeeded.
    case introduce

    /// Ekranda kaç saniye görünür kalacağı (bu süre sonunda kendiliğinden kaybolur).
    var displayDuration: TimeInterval {
        switch self {
        case .peek: 3.2
        case .dangle: 4.0
        case .wander: 3.4
        case .sit: 4.5
        case .bounce: 2.2
        case .greet: 3.0
        case .introduce: 6.5
        }
    }
}

@Observable
final class KenCompanion {
    private(set) var currentBehavior: KenBehavior?

    /// Bulut routine'inin ürettiği, dolaşırken söylenebilecek taze cümleler —
    /// canlı dinlenir, routine her çalıştığında otomatik güncellenir.
    private(set) var cloudLines: [String] = []

    /// Son ruh hali verisinden 0 (sıcak/olumlu) ... 1 (soğuk/zor) arası ton —
    /// Ken'in gövde rengini canlı besler. Veri yoksa nil (varsayılan renk).
    private(set) var moodTone: Double?

    /// Boşta kendiliğinden seçilebilecek davranışlar — kutlama ve karşılama
    /// sadece olaya bağlı tetiklendiği için buraya dahil değil.
    private static let idleBehaviors: [KenBehavior] = [.peek, .dangle, .wander, .sit]

    private var pauseCount = 0
    private var idleLoopStarted = false
    private var hideTask: Task<Void, Never>?
    private let roamingLinesRepository: KenRoamingLinesRepository
    private let moodToneRepository: KenMoodToneRepository

    private static let lastGreetDateKey = "ken.lastGreetDate"
    private static let hasIntroducedKey = "ken.hasIntroduced"

    init(roamingLinesRepository: KenRoamingLinesRepository, moodToneRepository: KenMoodToneRepository) {
        self.roamingLinesRepository = roamingLinesRepository
        self.moodToneRepository = moodToneRepository
        roamingLinesRepository.observe { [weak self] lines in
            self?.cloudLines = lines
        }
        moodToneRepository.observe { [weak self] tone in
            self?.moodTone = tone
        }
    }

    /// Bir şeyle etkileşimdeyken (yazı yazma vb.) Ken'in araya girmesini durdurur.
    /// Sayaç tabanlı — iç içe pause/resume çağrılarında da güvenli.
    func pause() { pauseCount += 1 }
    func resume() { pauseCount = max(0, pauseCount - 1) }

    /// Belirli bir davranışı hemen gösterir; süresi dolunca kendiliğinden gizlenir.
    func trigger(_ behavior: KenBehavior) {
        hideTask?.cancel()
        currentBehavior = behavior
        scheduleHide(after: behavior.displayDuration)
    }

    /// Ken'e dokunulduğunda çağrılır: tam o an kaybolmasın diye gizlenme
    /// sayacını birkaç saniye daha uzatır (balonu okuyacak vakti olsun diye).
    func keepAlive(extra: TimeInterval = 2.4) {
        guard currentBehavior != nil else { return }
        scheduleHide(after: extra)
    }

    private func scheduleHide(after duration: TimeInterval) {
        hideTask?.cancel()
        hideTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.currentBehavior = nil }
        }
    }

    /// Uygulamanın ömründe bir kez: Ken kendini tanıtır. Tetiklendiyse `true`
    /// döner — çağıran taraf aynı açılışta ayrıca günlük karşılamayı tetiklemesin diye.
    @discardableResult
    func triggerIntroductionIfNeeded() -> Bool {
        guard !UserDefaults.standard.bool(forKey: Self.hasIntroducedKey) else { return false }
        UserDefaults.standard.set(true, forKey: Self.hasIntroducedKey)
        trigger(.introduce)
        return true
    }

    /// Günün ilk açılışında bir kez "karşılama" davranışını tetikler.
    func markAppOpenedIfNeeded() {
        let today = Self.dayKey(for: Date())
        let last = UserDefaults.standard.string(forKey: Self.lastGreetDateKey)
        guard last != today else { return }
        UserDefaults.standard.set(today, forKey: Self.lastGreetDateKey)
        trigger(.greet)
    }

    /// Uygulama açıkken arada bir kendiliğinden bir davranış seçip oynatır.
    /// Sadece bir kez başlatılır (KenCompanionView her göründüğünde tekrar çağırsa da etkisizdir).
    func startIdleLoop() {
        guard !idleLoopStarted else { return }
        idleLoopStarted = true
        Task { [weak self] in
            while !Task.isCancelled {
                let wait = TimeInterval.random(in: 20...50)
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                guard let self else { return }
                await MainActor.run {
                    guard self.pauseCount == 0, self.currentBehavior == nil else { return }
                    self.trigger(Self.idleBehaviors.randomElement()!)
                }
            }
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}
