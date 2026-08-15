//
//  KenLineSelector.swift
//  Loveyaniask
//
//  Ken'in o an ne söyleyeceğine karar veren yer.
//
//  İki derdi çözüyor:
//  1) Tekrar. Eskiden sadece bir önceki cümle hatırlanıyordu, bu yüzden aynı
//     satırlar sık sık geri geliyordu. Artık son gösterilen cümleler
//     UserDefaults'ta kalıcı tutulup (uygulama kapansa da) havuzdan çıkarılıyor.
//  2) Bağlamsızlık. Havuz düz bir listeydi; artık saate, ruh haline, yaklaşan
//     özel güne ve o anki davranışa göre kategoriler ağırlıklanıyor.
//
//  Ruh hali sadece TONU ayarlar: zor tarafa kaydığında şefkatli cümleler öne
//  çıkar, şakacı/öneri cümleleri geri çekilir. Ken hiçbir koşulda kızmaz ve
//  hissin sebebini asla tahmin etmez.
//

import Foundation

/// Cümle seçimi için o anki durum.
struct KenLineContext {
    var daysTogether: Int
    var moodTone: Double?
    var hour: Int
    var upcoming: KenUpcomingDay?
    var milestone: Int?
    var missedDays: Int?
    var cloudLines: [String]
}

enum KenLineSelector {
    private static let recentKey = "ken.recentLines"
    /// Kaç cümle geriye kadar tekrar engellenecek.
    private static let recentLimit = 14

    /// O anki davranış ve bağlama uygun bir cümle seçer, seçtiğini hatırlar.
    static func line(for behavior: KenBehavior, context: KenLineContext) -> String? {
        guard let line = pick(from: pool(for: behavior, context: context)) else { return nil }
        remember(line)
        return line
    }

    /// Sahne adımlarının istediği tondan bir cümle (bkz. KenScene / KenBeat.say).
    static func line(for pool: KenLinePool, context: KenLineContext) -> String? {
        let source: [String]
        switch pool {
        case .thought: return line(for: .sit, context: context)
        case .sleepy: source = KenTapLines.sleepy
        case .playful: source = KenTapLines.playful
        case .affection: source = KenTapLines.affection
        case .curious: source = KenTapLines.presence + KenTapLines.identity
        }
        guard let picked = pick(from: source.map { ($0, 1.0) }) else { return nil }
        remember(picked)
        return picked
    }

    /// "Gıcık oldum" gibi kendi havuzu olan özel durumlar için.
    static func line(from lines: [String]) -> String? {
        guard let line = pick(from: lines.map { ($0, 1.0) }) else { return nil }
        remember(line)
        return line
    }

    // MARK: - Havuz

    private static func pool(for behavior: KenBehavior, context: KenLineContext) -> [(String, Double)] {
        switch behavior {
        case .celebrate:
            return weighted(KenTapLines.milestone(days: context.milestone ?? context.daysTogether), 1)
                + weighted(KenTapLines.celebration, 0.6)
        case .miss:
            return weighted(KenTapLines.missed(days: context.missedDays ?? 3), 1)
        case .snooze:
            return weighted(KenTapLines.sleepy, 1) + weighted(KenTapLines.night, 0.5)
        case .grumble, .dizzy, .held:
            return weighted(KenTapLines.thrown, 1)
        default:
            break
        }

        // Ruh hali zor tarafa kaydıysa ton yumuşar: şefkat öne, şakacılık geri.
        let hard = (context.moodTone ?? 0.35) > 0.62

        var pool = weighted(KenTapLines.presence, 1)
        pool += weighted(KenTapLines.affection, hard ? 1.4 : 1)
        pool += weighted(KenTapLines.playful, hard ? 0.25 : 1)
        pool += weighted(KenTapLines.suggestions, hard ? 0.4 : 1)
        pool += weighted(KenTapLines.identity, 0.8)
        pool += weighted(KenTapLines.dynamic(daysTogether: context.daysTogether), 0.7)

        if hard {
            pool += weighted(KenTapLines.comfort, 3)
        }
        if context.hour >= 22 || context.hour < 6 {
            pool += weighted(KenTapLines.night, 2.5)
        }
        if (6..<10).contains(context.hour) {
            pool += weighted(KenTapLines.morning, 2.5)
        }
        if let upcoming = context.upcoming, (0...5).contains(upcoming.daysRemaining) {
            pool += weighted(
                KenTapLines.upcoming(title: upcoming.title, daysRemaining: upcoming.daysRemaining),
                3.5
            )
        }
        // Bulut satırları o güne özel üretildiği için ağır basıyor.
        pool += weighted(context.cloudLines, 2.5)

        return pool
    }

    private static func weighted(_ lines: [String], _ weight: Double) -> [(String, Double)] {
        lines.map { ($0, weight) }
    }

    // MARK: - Seçim ve hafıza

    private static func pick(from pool: [(String, Double)]) -> String? {
        guard !pool.isEmpty else { return nil }
        let recent = Set(recentLines())
        // Yakında söylenenleri ele; geriye çok az kalıyorsa hepsini geri al,
        // yoksa Ken aynı iki cümleye sıkışıp kalır.
        var candidates = pool.filter { !recent.contains($0.0) }
        if candidates.count < 3 { candidates = pool }

        let total = candidates.reduce(0) { $0 + max(0, $1.1) }
        guard total > 0 else { return candidates.randomElement()?.0 }
        var roll = Double.random(in: 0..<total)
        for (line, weight) in candidates {
            roll -= max(0, weight)
            if roll < 0 { return line }
        }
        return candidates.last?.0
    }

    private static func recentLines() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentKey) ?? []
    }

    private static func remember(_ line: String) {
        var recent = recentLines()
        recent.removeAll { $0 == line }
        recent.append(line)
        if recent.count > recentLimit {
            recent.removeFirst(recent.count - recentLimit)
        }
        UserDefaults.standard.set(recent, forKey: recentKey)
    }
}
