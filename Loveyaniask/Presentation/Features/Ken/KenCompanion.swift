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

/// Ken'in sergileyebileceği davranışlar. `idleBehaviors` içindekiler boşta
/// kendiliğinden seçilir; kalanlar sadece belirli olaylarla tetiklenir
/// (puanlama, paylaşım, günün ilk açılışı, dönüm günü, uzun ayrılık).
enum KenBehavior: CaseIterable, Hashable {
    case peek
    case dangle
    case wander
    case sit
    /// Esneyip gerinme — özellikle sabahları.
    case stretch
    /// Kıvrılıp uyuklama — sadece gece geç saatlerde.
    case snooze
    case bounce
    /// Yuvarlak bir beraberlik gününde (100, 200, 365...) coşkulu kutlama.
    case celebrate
    case greet
    /// Uygulama günlerce açılmadıysa dönüşte: özlemiş hâli.
    case miss
    /// Sadece ilk girişte, bir kere: büyükçe belirir, kendini tanıtan bir
    /// konuşma balonu açar, sonra uçup gider. Bkz. triggerIntroductionIfNeeded.
    case introduce

    /// Ekranda kaç saniye görünür kalacağı (bu süre sonunda kendiliğinden kaybolur).
    var displayDuration: TimeInterval {
        switch self {
        case .peek: 3.2
        case .dangle: 4.0
        case .wander: 3.4
        case .sit: 4.5
        case .stretch: 4.2
        case .snooze: 6.0
        case .bounce: 2.4
        case .celebrate: 4.0
        case .greet: 3.0
        case .miss: 4.6
        case .introduce: 6.5
        }
    }

    /// Ken bu davranışta bir şey söylüyor mu — bazı anlar (kutlama, özlem,
    /// tanıtım) balonsuz eksik kalır, o yüzden garanti konuşur.
    var alwaysSpeaks: Bool {
        switch self {
        case .celebrate, .miss, .introduce: true
        default: false
        }
    }
}

/// Ken'i ne sıklıkta görmek istediğiniz. Profil'deki karttan seçilir.
enum KenFrequency: String, CaseIterable, Identifiable {
    case rare
    case normal
    case often

    static let storageKey = "ken.frequency"

    static var current: KenFrequency {
        KenFrequency(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .normal
    }

    var id: String { rawValue }

    var label: String {
        switch self {
        case .rare: "Az"
        case .normal: "Normal"
        case .often: "Sık"
        }
    }

    /// Boşta iki görünme arasındaki bekleme aralığı (saniye).
    var idleInterval: ClosedRange<TimeInterval> {
        switch self {
        case .rare: 55...120
        case .normal: 20...50
        case .often: 12...28
        }
    }
}

/// Yaklaşan özel gün — Ken'in söyleyeceği cümleyi bağlamlandırmak için
/// HomeView tarafından beslenir.
struct KenUpcomingDay: Equatable {
    let title: String
    let daysRemaining: Int
}

@Observable
final class KenCompanion {
    private(set) var currentBehavior: KenBehavior?

    /// Bulut routine'inin ürettiği, dolaşırken söylenebilecek taze cümleler —
    /// canlı dinlenir, routine her çalıştığında otomatik güncellenir.
    private(set) var cloudLines: [String] = []

    /// Son ruh hali verisinden 0 (sıcak/olumlu) ... 1 (soğuk/zor) arası ton —
    /// Ken'in gövde rengini ve hangi davranışı seçtiğini canlı besler.
    private(set) var moodTone: Double?

    /// Bulut routine'inin ana sayfaya bıraktığı not (bkz. KenHomeNoteCard).
    private(set) var homeNote: KenNote?

    /// Yaklaşan özel gün (varsa) — HomeView her göründüğünde günceller.
    var upcomingSpecialDay: KenUpcomingDay?

    /// Bugün kutlanan yuvarlak beraberlik günü; kutlama bitince temizlenir.
    private(set) var celebratingDays: Int?
    /// Uygulamanın kaç gün açılmadığı; "özledim" hâli bitince temizlenir.
    private(set) var missedDays: Int?

    private var pauseCount = 0
    private var idleLoopStarted = false
    private var hideTask: Task<Void, Never>?
    private let roamingLinesRepository: KenRoamingLinesRepository
    private let moodToneRepository: KenMoodToneRepository
    private let homeNoteRepository: KenHomeNoteRepository

    private static let lastGreetDateKey = "ken.lastGreetDate"
    private static let hasIntroducedKey = "ken.hasIntroduced"
    private static let lastMilestoneKey = "ken.lastMilestone"

    init(
        roamingLinesRepository: KenRoamingLinesRepository,
        moodToneRepository: KenMoodToneRepository,
        homeNoteRepository: KenHomeNoteRepository
    ) {
        self.roamingLinesRepository = roamingLinesRepository
        self.moodToneRepository = moodToneRepository
        self.homeNoteRepository = homeNoteRepository
        roamingLinesRepository.observe { [weak self] lines in
            self?.cloudLines = lines
        }
        moodToneRepository.observe { [weak self] tone in
            self?.moodTone = tone
        }
        homeNoteRepository.observe { [weak self] note in
            self?.homeNote = note
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

    /// Olayla tetiklenen sevinç (paylaşım, puanlama, not ekleme...). Zor bir
    /// dönemdeyse coşkulu zıplama yerine sessiz bir "buradayım" tepkisi verir —
    /// kızmaz, sadece sesini kısar.
    func celebrateEvent() {
        trigger((moodTone ?? 0) > 0.65 ? .peek : .bounce)
    }

    /// Zaten görünürken tekrar tetiklemeyen tepki. Art arda gelen küçük
    /// etkileşimlerde (ruh hali çiplerini deneyerek seçmek gibi) Ken'in yanıp
    /// sönen bir bildirime dönüşmemesi için.
    func reactIfIdle(_ behavior: KenBehavior) {
        guard currentBehavior == nil else { return }
        trigger(behavior)
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
            await MainActor.run {
                self?.currentBehavior = nil
                self?.celebratingDays = nil
                self?.missedDays = nil
            }
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

    /// Günün ilk açılışında bir kez tepki verir: yuvarlak bir beraberlik günüyse
    /// kutlar, uygulama günlerdir açılmadıysa özlemini gösterir, normalde karşılar.
    func markAppOpenedIfNeeded(daysTogether: Int) {
        let today = Self.dayKey(for: Date())
        let last = UserDefaults.standard.string(forKey: Self.lastGreetDateKey)
        guard last != today else { return }
        UserDefaults.standard.set(today, forKey: Self.lastGreetDateKey)

        if let milestone = Self.milestone(for: daysTogether),
           UserDefaults.standard.integer(forKey: Self.lastMilestoneKey) != milestone {
            UserDefaults.standard.set(milestone, forKey: Self.lastMilestoneKey)
            celebratingDays = milestone
            trigger(.celebrate)
            return
        }

        if let last, let gap = Self.dayGap(from: last, to: today), gap >= 3 {
            missedDays = gap
            trigger(.miss)
            return
        }

        trigger(.greet)
    }

    /// Uygulama açıkken arada bir kendiliğinden bir davranış seçip oynatır.
    /// Sadece bir kez başlatılır (KenCompanionView her göründüğünde tekrar çağırsa da etkisizdir).
    func startIdleLoop() {
        guard !idleLoopStarted else { return }
        idleLoopStarted = true
        Task { [weak self] in
            while !Task.isCancelled {
                let wait = TimeInterval.random(in: KenFrequency.current.idleInterval)
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                guard let self else { return }
                await MainActor.run {
                    guard self.pauseCount == 0, self.currentBehavior == nil else { return }
                    self.trigger(self.pickIdleBehavior())
                }
            }
        }
    }

    /// Boşta hangi davranışın çıkacağı sabit değil: saate ve ruh haline göre
    /// ağırlıklanıyor. Zor bir dönemdeyken (tone yüksek) sakin davranışlar öne
    /// çıkıyor, keyifliyken hareketli olanlar. Ruh hali Ken'i ASLA sinirlendirmez;
    /// sadece hangi hâlde göründüğünü etkiler.
    private func pickIdleBehavior() -> KenBehavior {
        let hour = Calendar.current.component(.hour, from: Date())
        let isNight = hour >= 23 || hour < 6
        let isMorning = (6..<10).contains(hour)
        let tone = moodTone ?? 0.35
        let calm = 0.7 + 0.9 * tone
        let lively = 1.3 - 0.9 * tone

        var weights: [(KenBehavior, Double)] = [
            (.peek, calm),
            (.sit, calm),
            (.dangle, 0.85 * lively),
            (.wander, lively),
            (.stretch, 0.55 * lively + (isMorning ? 0.9 : 0))
        ]
        if isNight {
            weights.append((.snooze, 2.0))
        }
        return Self.weightedPick(weights) ?? .sit
    }

    private static func weightedPick(_ weights: [(KenBehavior, Double)]) -> KenBehavior? {
        let total = weights.reduce(0) { $0 + max(0, $1.1) }
        guard total > 0 else { return weights.first?.0 }
        var roll = Double.random(in: 0..<total)
        for (behavior, weight) in weights {
            roll -= max(0, weight)
            if roll < 0 { return behavior }
        }
        return weights.last?.0
    }

    /// Kutlanmaya değer yuvarlak günler: her 100 gün ve her yıl.
    private static func milestone(for days: Int) -> Int? {
        guard days > 0 else { return nil }
        return (days % 100 == 0 || days % 365 == 0) ? days : nil
    }

    private static func dayGap(from: String, to: String) -> Int? {
        let formatter = dayFormatter
        guard let start = formatter.date(from: from), let end = formatter.date(from: to) else { return nil }
        return Calendar.current.dateComponents([.day], from: start, to: end).day
    }

    private static func dayKey(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
