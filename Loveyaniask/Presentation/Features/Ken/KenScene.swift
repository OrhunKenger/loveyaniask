//
//  KenScene.swift
//  Loveyaniask
//
//  Ken'in sahne dili.
//
//  Tek atımlık eylemler ("saklandı", "zıpladı") bir NPC'yi ucuz gösterir —
//  omuz silkme gibi durur. Niyet okunması için sahnenin adımları olmalı:
//  karta yürü → dur, bak → arkasına geç → kaybol → tek göz göster → geri çekil.
//
//  Bu yüzden davranış kodda değil, VERİDE tanımlı: her sahne bir adım listesi.
//  Motoru bir kez yazdık; yeni sahne eklemek artık kod değil içerik işi.
//

import Foundation
import CoreGraphics

/// Ken'in dünyasındaki sabit noktalar. Ekran boyutuna göre çözülüyor.
/// "Rastgele bir x'e yürü" yerine "şu çapaya git ve orada şunu yap" —
/// Ken'i ekranın üstünde yüzen bir şey olmaktan çıkarıp uygulamanın
/// içinde yaşayan bir şeye çeviren fark bu.
enum KenAnchor: Equatable {
    /// Ekranın üst kenarı; oradan sarkar.
    case ceiling
    /// Alt bar hizası; oraya tüner.
    case tabBar
    /// Ekranın solu / sağı (kenardan içeri bakmak için).
    case leftEdge
    case rightEdge
    /// Ekranın ortası.
    case center
    /// Kartların bulunduğu bant — arkasına geçmek için.
    case behindCards
    /// Rastgele bir yer — dolaşmak için.
    case wherever
}

/// Bir sahnenin tek adımı.
enum KenBeat: Equatable {
    /// Çapaya yürüyerek git (varana kadar sürer).
    case walk(to: KenAnchor)
    /// Çapaya koşarak git — olaylara koşarken kullanılıyor.
    case run(to: KenAnchor)
    /// Bir pozu belirtilen süre boyunca tut.
    case pose(KenBehavior, seconds: TimeInterval)
    /// Hiçbir şey yapmadan bekle.
    case wait(seconds: TimeInterval)
    /// Bir şey söyle (havuz adı; cümleyi KenLineSelector seçer).
    case say(KenLinePool)
    /// Mırıldan — küçük nota işaretleri çıkar.
    case hum(seconds: TimeInterval)
    /// Bakışını bir yöne çevir (-1 sol ... 1 sağ).
    case look(x: CGFloat, y: CGFloat, seconds: TimeInterval)
    /// İçeriğin arkasına geçip görünmez ol.
    case hide(seconds: TimeInterval)
    /// Saklandığı yerden tek gözünü göster.
    case peekOut(seconds: TimeInterval)
    /// Bulunduğu yere bir iz bırak.
    case leaveTrace
    /// Bıraktığı izlerden birini temizle (temizlerken yakalanabilir).
    case cleanTrace
}

/// Cümle havuzları — sahneler hangi tondan konuşacağını böyle söylüyor.
enum KenLinePool: Equatable {
    case thought      // kendi kendine, 3. şahıs, sizin hakkınızda
    case sleepy
    case playful
    case affection
    case curious      // yeni bir şeye bakarken
}

/// Ken'in hangi dürtüden doğduğu — sahne seçimi buna göre yapılıyor.
enum KenDrive: String, CaseIterable {
    case sleep
    case boredom
    case closeness
    case curiosity
}

struct KenScene: Equatable {
    let id: String
    /// Hangi dürtüyü doyuruyor.
    let drive: KenDrive
    let beats: [KenBeat]
    /// Sadece gece / sadece gündüz gibi kısıtlar.
    var nightOnly = false
    var dayOnly = false
    /// Seçilme ağırlığı — sık görülmesini istediklerimiz yüksek.
    var weight: Double = 1

    init(_ id: String, _ drive: KenDrive, _ beats: [KenBeat],
         nightOnly: Bool = false, dayOnly: Bool = false, weight: Double = 1) {
        self.id = id
        self.drive = drive
        self.beats = beats
        self.nightOnly = nightOnly
        self.dayOnly = dayOnly
        self.weight = weight
    }
}

/// Sahne kütüphanesi.
///
/// TASARIM KURALI: Ken uygulamaya 15-20 saniyeliğine bakan birine "kendi
/// işiyle meşgul" görünmeli. Bu yüzden sahneler KISA ve HAREKETLİ:
/// - her sahnede en az bir yürüme/tırmanma var (hareket = meşguliyet sinyali)
/// - duruş pozları 2.5 saniyeyi geçmiyor (uzun poz ölü zaman demek)
/// - bir sahne 6-12 saniye sürüyor, sonra hemen yenisi başlıyor
///
/// İlk sürümde pozlar 5-8 saniyeydi ve Ken çoğu zaman oturuyordu; kısa bir
/// ziyarette hiçbir şey yapmıyor gibi görünüyordu.
enum KenScenes {
    static let all: [KenScene] = sleep + boredom + closeness + curiosity

    // MARK: - Uyku (kısa kestirmeler; gece uzuyor)

    private static let sleep: [KenScene] = [
        KenScene("kose-kestir", .sleep, [
            .walk(to: .wherever),
            .pose(.stretch, seconds: 1.6),
            .say(.sleepy),
            .pose(.snooze, seconds: 9)
        ], nightOnly: true, weight: 2),

        KenScene("kisa-sekerleme", .sleep, [
            .pose(.stretch, seconds: 1.4),
            .pose(.snooze, seconds: 5),
            .pose(.stretch, seconds: 1.2),
            .walk(to: .wherever)
        ]),

        KenScene("esne-gerin", .sleep, [
            .pose(.stretch, seconds: 2.2),
            .hum(seconds: 1.8),
            .walk(to: .wherever)
        ])
    ]

    // MARK: - Can sıkıntısı: kendi kendine oyun (en sık görülen grup)

    private static let boredom: [KenScene] = [
        KenScene("kuyruk-kovala", .boredom, [
            .look(x: 0.9, y: 0.4, seconds: 0.5),
            .pose(.bounce, seconds: 1.6),
            .walk(to: .wherever),
            .pose(.bounce, seconds: 1.2),
            .hum(seconds: 1.5)
        ], weight: 1.6),

        KenScene("tavana-sark", .boredom, [
            .walk(to: .ceiling),
            .pose(.dangle, seconds: 3),
            .hum(seconds: 1.8),
            .pose(.held, seconds: 0.5),
            .pose(.dizzy, seconds: 1),
            .walk(to: .wherever)
        ], weight: 1.4),

        KenScene("kartin-arkasina-saklan", .boredom, [
            .walk(to: .behindCards),
            .hide(seconds: 2),
            .peekOut(seconds: 1.4),
            .hide(seconds: 1.2),
            .pose(.peek, seconds: 1.2),
            .walk(to: .wherever)
        ], weight: 1.6),

        KenScene("bastan-basa-kos", .boredom, [
            .run(to: .leftEdge),
            .pose(.peek, seconds: 1),
            .run(to: .rightEdge),
            .pose(.peek, seconds: 1),
            .hum(seconds: 1.5)
        ], weight: 1.5),

        KenScene("tab-bara-tune", .boredom, [
            .walk(to: .tabBar),
            .pose(.sit, seconds: 2),
            .look(x: 0, y: -0.6, seconds: 1.2),
            .hum(seconds: 1.5),
            .walk(to: .wherever)
        ], weight: 1.2),

        KenScene("zikzak-dolan", .boredom, [
            .walk(to: .wherever),
            .look(x: -0.7, y: 0, seconds: 0.5),
            .walk(to: .wherever),
            .look(x: 0.7, y: 0, seconds: 0.5),
            .walk(to: .wherever)
        ], weight: 1.6),

        KenScene("iz-birak", .boredom, [
            .walk(to: .wherever),
            .leaveTrace,
            .pose(.bounce, seconds: 1),
            .say(.playful),
            .walk(to: .wherever)
        ], weight: 0.7),

        KenScene("izini-temizle", .boredom, [
            .walk(to: .wherever),
            .cleanTrace,
            .look(x: -0.6, y: 0, seconds: 0.4),
            .look(x: 0.6, y: 0, seconds: 0.4),
            .walk(to: .wherever)
        ], weight: 0.9),

        KenScene("tirman-in", .boredom, [
            .walk(to: .ceiling),
            .pose(.dangle, seconds: 1.6),
            .pose(.held, seconds: 0.4),
            .pose(.dizzy, seconds: 0.8),
            .run(to: .wherever)
        ], weight: 1.1)
    ]

    // MARK: - Yakınlık

    private static let closeness: [KenScene] = [
        KenScene("yanina-kos", .closeness, [
            .run(to: .center),
            .look(x: 0, y: -0.5, seconds: 1),
            .say(.affection),
            .pose(.bounce, seconds: 1.2),
            .pose(.sit, seconds: 2)
        ], weight: 1.6),

        KenScene("dikkat-cek", .closeness, [
            .pose(.greet, seconds: 1.8),
            .say(.affection),
            .pose(.bounce, seconds: 1.2),
            .walk(to: .wherever)
        ], weight: 1.3),

        KenScene("sessizce-eslik", .closeness, [
            .walk(to: .center),
            .pose(.sit, seconds: 2.5),
            .hum(seconds: 2),
            .look(x: 0, y: -0.4, seconds: 1.2),
            .walk(to: .wherever)
        ])
    ]

    // MARK: - Merak

    private static let curiosity: [KenScene] = [
        KenScene("ekrana-bak", .curiosity, [
            .run(to: .center),
            .look(x: 0, y: -0.7, seconds: 1.5),
            .say(.curious),
            .walk(to: .wherever)
        ], weight: 1.4),

        KenScene("etrafi-kolacan", .curiosity, [
            .pose(.peek, seconds: 1),
            .look(x: -0.8, y: 0, seconds: 0.7),
            .look(x: 0.8, y: 0, seconds: 0.7),
            .walk(to: .wherever),
            .say(.thought)
        ], weight: 1.2)
    ]
}
