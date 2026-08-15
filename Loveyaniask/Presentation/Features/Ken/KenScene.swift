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
    /// Kulübe — uyku ve saklanma yeri.
    case home
    /// Ekranın üst kenarı; oradan sarkar.
    case ceiling
    /// Alt bar hizası; oraya tüner.
    case tabBar
    /// Ekranın solu / sağı (kenardan içeri bakmak için).
    case leftEdge
    case rightEdge
    /// Ekranın ortası.
    case center
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

/// Sahne kütüphanesi. Buraya eklemek serbest ve ucuz — motor değişmiyor.
enum KenScenes {
    static let all: [KenScene] = sleep + boredom + closeness + curiosity

    // MARK: - Uyku

    private static let sleep: [KenScene] = [
        KenScene("eve-git-uyu", .sleep, [
            .walk(to: .home),
            .pose(.stretch, seconds: 2.2),
            .say(.sleepy),
            .pose(.snooze, seconds: 40)
        ], nightOnly: true, weight: 2),

        KenScene("kestirme", .sleep, [
            .pose(.stretch, seconds: 1.8),
            .pose(.snooze, seconds: 18)
        ]),

        KenScene("esne-gerin", .sleep, [
            .pose(.stretch, seconds: 3.5),
            .hum(seconds: 3)
        ])
    ]

    // MARK: - Can sıkıntısı: kendi kendine oyun

    private static let boredom: [KenScene] = [
        KenScene("kuyruk-kovala", .boredom, [
            .pose(.bounce, seconds: 2.0),
            .look(x: 0.9, y: 0.4, seconds: 0.6),
            .pose(.wander, seconds: 1.4),
            .pose(.sit, seconds: 1.5),
            .hum(seconds: 2.5)
        ], weight: 1.4),

        KenScene("tavana-sark", .boredom, [
            .walk(to: .ceiling),
            .pose(.dangle, seconds: 6),
            .hum(seconds: 3),
            .pose(.held, seconds: 0.6),
            .pose(.dizzy, seconds: 1.2),
            .pose(.sit, seconds: 1.5)
        ], weight: 1.2),

        KenScene("kartin-arkasina-saklan", .boredom, [
            .walk(to: .wherever),
            .look(x: 0, y: -0.4, seconds: 0.8),
            .hide(seconds: 3.5),
            .peekOut(seconds: 2.0),
            .hide(seconds: 1.5),
            .pose(.peek, seconds: 1.5)
        ], weight: 1.5),

        KenScene("kenarda-dolan", .boredom, [
            .walk(to: .leftEdge),
            .pose(.sit, seconds: 2),
            .hum(seconds: 3),
            .walk(to: .rightEdge),
            .pose(.peek, seconds: 2)
        ]),

        KenScene("tab-bara-tune", .boredom, [
            .walk(to: .tabBar),
            .pose(.sit, seconds: 5),
            .look(x: 0, y: -0.6, seconds: 2),
            .hum(seconds: 3)
        ]),

        KenScene("iz-birak", .boredom, [
            .walk(to: .wherever),
            .pose(.sit, seconds: 1.5),
            .leaveTrace,
            .pose(.bounce, seconds: 1.2),
            .say(.playful)
        ], weight: 0.6),

        KenScene("izini-temizle", .boredom, [
            .walk(to: .wherever),
            .pose(.sit, seconds: 1.2),
            .cleanTrace,
            .look(x: -0.6, y: 0, seconds: 0.5),
            .look(x: 0.6, y: 0, seconds: 0.5),
            .pose(.wander, seconds: 1.5)
        ], weight: 0.8)
    ]

    // MARK: - Yakınlık

    private static let closeness: [KenScene] = [
        KenScene("yanina-gel", .closeness, [
            .walk(to: .center),
            .look(x: 0, y: -0.5, seconds: 1.5),
            .say(.affection),
            .pose(.sit, seconds: 5)
        ], weight: 1.5),

        KenScene("dikkat-cek", .closeness, [
            .pose(.greet, seconds: 2.2),
            .say(.affection),
            .pose(.bounce, seconds: 1.6),
            .pose(.sit, seconds: 2)
        ]),

        KenScene("sessizce-esllik", .closeness, [
            .walk(to: .center),
            .pose(.sit, seconds: 8),
            .hum(seconds: 4),
            .look(x: 0, y: -0.4, seconds: 2)
        ], weight: 1.2)
    ]

    // MARK: - Merak

    private static let curiosity: [KenScene] = [
        KenScene("ekrana-bak", .curiosity, [
            .walk(to: .center),
            .look(x: 0, y: -0.7, seconds: 2.5),
            .say(.curious),
            .pose(.sit, seconds: 2)
        ], weight: 1.3),

        KenScene("etrafi-kolacan", .curiosity, [
            .pose(.peek, seconds: 1.5),
            .look(x: -0.8, y: 0, seconds: 1),
            .look(x: 0.8, y: 0, seconds: 1),
            .pose(.wander, seconds: 2),
            .say(.thought)
        ])
    ]
}
