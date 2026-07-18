//
//  CycleContentEngine.swift
//  Loveyaniask
//
//  Akıllı içerik motoru: döngü fazına göre Şevval'e sıcak mesaj + faz ipucu,
//  Orhun'a "bugün ne yapmalı" ipucu üretir. Her faz için büyük havuz; içerik
//  güne göre DÖNER (deterministik) → aynı gün sabit, gün değişince değişir,
//  tekrar etmez.
//

import Foundation

/// Bir günün üreteceği içerik.
struct PhaseContent {
    let sevvalMessage: String
    let sevvalTip: String
    let orhunTip: String
}

enum CycleContentEngine {

    /// Verilen faz ve gün için içerik. Gün indeksi havuzda gezinir (deterministik).
    static func content(for phase: CyclePhase, on date: Date = Date()) -> PhaseContent {
        let index = dayIndex(date)
        return PhaseContent(
            sevvalMessage: sevvalMessages[phase]?.rotated(index) ?? "",
            // İpuçlarını mesajla aynı ritimde dönmesin diye küçük ofsetler.
            sevvalTip: sevvalTips[phase]?.rotated(index + 1) ?? "",
            orhunTip: orhunTips[phase]?.rotated(index + 2) ?? ""
        )
    }

    /// Referans günden bu yana geçen gün sayısı — günlük dönüş indeksi.
    private static func dayIndex(_ date: Date) -> Int {
        Int(date.timeIntervalSince1970 / 86_400)
    }

    // MARK: - Şevval'e sıcak mesajlar

    private static let sevvalMessages: [CyclePhase: [String]] = [
        .menstrual: [
            "Bugün biraz zorlu olabilir ama yalnız değilsin — buradayım 💗",
            "Kendine nazik ol, dinlenmek de bir güçtür. Seni seviyorum 🌷",
            "Sıcak bir çay, battaniye ve ben... bu günleri birlikte atlatırız 🍵",
            "Karnın ağrıyorsa söyle, sana bir masaj borcum var 🤍",
            "Bugün ne istersen onu hak ediyorsun, şımart kendini ✨",
            "Zor günler geçer, sen hep güzelsin. Sarılmak serbest 🫂",
        ],
        .follicular: [
            "Enerjin geri geliyor! Bugün kendini daha canlı hissedebilirsin 🌱",
            "Yeni bir döngü, yeni bir başlangıç. İçin ışıl ışıl ✨",
            "Moralin yükseliyor, ben de senin enerjine bayılıyorum 💛",
            "Planladığın o şeye başlamak için harika bir gün 🚀",
            "Kendini iyi hissettiğin bu günlerin tadını çıkar 🌼",
        ],
        .fertile: [
            "Bugün çekiciliğin tavan — farkında mısın? 😍",
            "Kendine güvenin en yüksek günlerdesin, parlıyorsun ✨",
            "Enerjin ve neşen bulaşıcı, sana bakmaya doyamıyorum 💗",
            "Bugün en iyi hissettiğin dönemdesin, tadını çıkar 🌼",
        ],
        .ovulation: [
            "Bugün döngünün zirvesi — enerjin ve çekiciliğin en yüksek 🥚✨",
            "Kendini güçlü ve çekici hissedebilirsin, hak ediyorsun 💫",
            "En parlak günündesin, sana hayranım 😍",
            "İçindeki ışık bugün daha da belirgin 🌟",
        ],
        .luteal: [
            "Sakinleşme dönemi — kendine biraz yavaşlama izni ver 🌙",
            "Bugün içe dönmek isteyebilirsin, bu çok doğal 🤍",
            "Enerjin biraz düşebilir; acele etme, buradayım 💗",
            "Kendine küçük mutluluklar hazırla, hak ediyorsun 🍫",
            "Rahat kıyafetler, sıcak bir içecek ve huzur 🍵",
        ],
        .pms: [
            "Bugün duyguların yoğun olabilir — hepsi geçerli, yanındayım 💗",
            "Moralin inip çıkabilir, bu senin suçun değil. Sarılalım 🫂",
            "Kendine karşı nazik ol, mükemmel olmak zorunda değilsin 🤍",
            "Canın sıkkınsa söyle, seni dinlemek isterim 💌",
            "Bu günler zor ama geçici. Seni çok seviyorum 🌷",
            "Ağlamak istersen ağla, gülmek istersen gül — hepsi serbest 💞",
        ],
    ]

    // MARK: - Şevval'e faz ipuçları

    private static let sevvalTips: [CyclePhase: [String]] = [
        .menstrual: [
            "Bol su iç ve demir açısından zengin besinler ye (ıspanak, kırmızı et) 🥩",
            "Ilık bir duş krampları yatıştırır 🚿",
            "Kafein ağrıyı artırabilir, bugün biraz azalt ☕️",
            "Hafif yürüyüş bile kramplara iyi gelir 🚶‍♀️",
        ],
        .follicular: [
            "Enerjin yüksek — spor ve hareket için ideal dönem 🏃‍♀️",
            "Yaratıcılığın artıyor, yeni bir şeye başla 🎨",
            "Protein ve taze sebzeler seni daha diri tutar 🥗",
            "Sosyalleşmek için güzel bir dönem, plan yap 🥂",
        ],
        .fertile: [
            "Enerjin yüksek, sevdiğin bir aktiviteye yönel 💃",
            "Cildin bugün daha parlak olabilir, tadını çıkar ✨",
            "Bol su ve hafif beslenme seni dinç tutar 💧",
            "Kendine güvenin yüksek — o cesur adımı at 🚀",
        ],
        .ovulation: [
            "Enerjin doruğunda — önemli işleri bugüne al ⚡️",
            "Bol su iç, hafif ve dengeli beslen 💧",
            "Kendine güvenin yüksek, sosyal ol 🥂",
        ],
        .luteal: [
            "Şeker krizleri olabilir; kompleks karbonhidrat tercih et 🍠",
            "Magnezyum (kuruyemiş, muz) ruh halini dengeler 🍌",
            "Uykuna özen göster, dinlenmek iyi gelir 😴",
            "Kafeini azalt, gerginliği artırabilir ☕️",
        ],
        .pms: [
            "Tuzlu/şekerli isteği artabilir; su ve dengeli beslenme yardımcı olur 💧",
            "Hafif egzersiz gerginliği azaltır 🧘‍♀️",
            "Erken uyku ruh halini toparlar 😴",
            "Kendine 'hayır deme' hakkı tanı, dinlen 🌙",
        ],
    ]

    // MARK: - Orhun'a "bugün ne yapmalı" ipuçları

    private static let orhunTips: [CyclePhase: [String]] = [
        .menstrual: [
            "Şevval'in ilk günleri — sıcak bir termofor ve çikolata harika olur 🍫",
            "Bugün ekstra sabır ve sarılma günü. Yanında ol 🫂",
            "En sevdiği yemeği ısmarla, küçük bir sürpriz moralini yükseltir 🍜",
            "Ağrısı varsa sırt/karın masajı teklif et 💆‍♀️",
        ],
        .follicular: [
            "Şevval enerjik — birlikte bir aktivite ya da gezi planlayın 🚶",
            "Bugün onu bir şeye davet et, 'evet' deme ihtimali yüksek 😄",
            "Enerjisine eşlik et, birlikte yeni bir şey deneyin ✨",
            "Küçük bir randevu ayarla, keyfi yerinde olacak 💕",
        ],
        .fertile: [
            "Şevval bugün enerjik ve neşeli — güzel vakit geçirin 💕",
            "İltifat et, farkında ol; bugün ışıldıyor ✨",
            "Romantik bir akşam için güzel bir zaman 🌙",
            "Enerjisine ayak uydur, keyfini paylaşın 😊",
        ],
        .ovulation: [
            "Şevval bugün zirvede — birlikte güzel bir şey yapın ✨",
            "Bol iltifat, bol ilgi. Keyfi yerinde 💕",
            "Enerjik ve neşeli; planlarınıza bugün yer açın 😊",
        ],
        .luteal: [
            "Şevval'in enerjisi düşebilir — sakin bir akşam planla 🌙",
            "Küçük jestler bugün çok değerli: bir çikolata, bir mesaj 🍫",
            "Sabırlı ve anlayışlı ol, yanında olduğunu hissettir 🤍",
            "Onu rahatlat: film, sarılma, sıcak çay 🍵",
        ],
        .pms: [
            "PMS dönemi — bugün ekstra sabır ve şefkat günü 🤍",
            "Tartışma çıkarma; dinle ve anla. Bir sarılma çok şey söyler 🫂",
            "Küçük sürprizler (çikolata, çiçek, sevgi mesajı) moralini yükseltir 🍫",
            "'Buradayım, seni seviyorum' demen bugün altın değerinde 💌",
        ],
    ]
}

private extension Array {
    /// Negatif olmayan indeksle güvenli döngüsel erişim.
    func rotated(_ index: Int) -> Element? {
        guard !isEmpty else { return nil }
        let i = ((index % count) + count) % count
        return self[i]
    }
}
