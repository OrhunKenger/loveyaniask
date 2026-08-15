//
//  KenCompanion.swift
//  Loveyaniask
//
//  Ken'in dış dünyayla bağlantısı: buluttan gelen içerik (dolaşma cümleleri,
//  ana sayfa notu, ruh hali tonu) ve uygulamadan gelen olaylar (paylaşım,
//  puanlama, not ekleme, günün ilk açılışı).
//
//  Ken'in NEREDE olduğu ve NE YAPTIĞI burada değil, KenWorld'de — bu sınıf
//  sadece olayları oraya iletiyor. Eskiden Ken'i "gösterip gizleyen" zamanlayıcı
//  buradaydı; Ken artık hiç kaybolmadığı için o mantık tamamen kalktı.
//

import Foundation
import Observation

/// Ken'in sergileyebileceği pozlar. Bir kısmı kalıcı bir duruma karşılık gelir
/// (KenActivity üzerinden), bir kısmı olayla tetiklenen kısa tepkilerdir.
enum KenBehavior: CaseIterable, Hashable {
    case peek
    case dangle
    case wander
    case sit
    /// Esneyip gerinme — özellikle sabahları.
    case stretch
    /// Kıvrılıp uyuklama.
    case snooze
    case bounce
    /// Yuvarlak bir beraberlik gününde (100, 200, 365...) coşkulu kutlama.
    case celebrate
    case greet
    /// Uygulama günlerce açılmadıysa dönüşte: özlemiş hâli.
    case miss
    /// Sadece ilk girişte, bir kere: kendini tanıtır.
    case introduce
    /// Parmakla tutulmuş ya da havada uçuyor — çırpınıyor.
    case held
    /// Sert düşüşten sonra sersemlemiş.
    case dizzy
    /// Doğrulup söylenme (fırlatıldıktan sonra).
    case grumble

    /// Olayla tetiklenen tepkilerde pozun ekranda kalma süresi.
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
        case .held: 1.0
        case .dizzy: 1.7
        case .grumble: 2.4
        }
    }

    /// Ken bu tepkide bir şey söylüyor mu — bazı anlar (kutlama, özlem,
    /// tanıtım) balonsuz eksik kalır, o yüzden garanti konuşur.
    var alwaysSpeaks: Bool {
        switch self {
        case .celebrate, .miss, .introduce, .grumble: true
        default: false
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
    /// Ken'in kendisi: konumu, ne yaptığı, fiziği.
    let world = KenWorld()

    /// Bulut routine'inin ürettiği, dolaşırken söylenebilecek taze cümleler.
    private(set) var cloudLines: [String] = []

    /// Son ruh hali verisinden 0 (sıcak/olumlu) ... 1 (soğuk/zor) arası ton —
    /// Ken'in gövde rengini besler.
    private(set) var moodTone: Double?

    /// Bulut routine'inin ana sayfaya bıraktığı not (bkz. KenHomeNoteCard).
    private(set) var homeNote: KenNote?

    /// Yaklaşan özel gün (varsa) — HomeView her göründüğünde günceller.
    var upcomingSpecialDay: KenUpcomingDay?

    /// Bugün kutlanan yuvarlak beraberlik günü ve uygulamanın kaç gün
    /// açılmadığı — sadece söylenecek cümleyi bağlamlandırmak için.
    private(set) var celebratingDays: Int?
    private(set) var missedDays: Int?

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

    // MARK: - Olaylar

    func pause() { world.pause() }
    func resume() { world.resume() }

    /// Belirli bir tepkiyi hemen oynatır.
    func trigger(_ behavior: KenBehavior) {
        world.react(behavior, seconds: behavior.displayDuration)
    }

    /// Olayla tetiklenen sevinç (paylaşım, puanlama, not ekleme...). Zor bir
    /// dönemdeyse coşkulu zıplama yerine sessiz bir "buradayım" tepkisi verir —
    /// kızmaz, sadece sesini kısar.
    func celebrateEvent() {
        trigger((moodTone ?? 0) > 0.65 ? .peek : .bounce)
    }

    /// Zaten bir şeyle meşgulken araya girmeyen tepki.
    func reactIfIdle(_ behavior: KenBehavior) {
        world.reactIfResting(behavior, seconds: behavior.displayDuration)
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
            clearContext(after: KenBehavior.celebrate.displayDuration)
            return
        }

        if let last, let gap = Self.dayGap(from: last, to: today), gap >= 3 {
            missedDays = gap
            trigger(.miss)
            clearContext(after: KenBehavior.miss.displayDuration)
            return
        }

        trigger(.greet)
    }

    private func clearContext(after seconds: TimeInterval) {
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            await MainActor.run {
                self?.celebratingDays = nil
                self?.missedDays = nil
            }
        }
    }

    /// Kutlanmaya değer yuvarlak günler: her 100 gün ve her yıl.
    private static func milestone(for days: Int) -> Int? {
        guard days > 0 else { return nil }
        return (days % 100 == 0 || days % 365 == 0) ? days : nil
    }

    private static func dayGap(from: String, to: String) -> Int? {
        guard let start = dayFormatter.date(from: from), let end = dayFormatter.date(from: to) else { return nil }
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
