//
//  KenTapLines.swift
//  Loveyaniask
//
//  Ken'e dokununca çıkabilecek, kod içinde sabit (AI üretmeyen) cümle havuzu.
//  Kategorilere ayrılmış statik içerik + beraberlik gün sayısına göre üretilen
//  dinamik satırlar. Bulut tarafının ürettiği taze satırlar (KenCompanion.cloudLines)
//  bu havuza KenCompanionView'da ayrıca eklenir — burası sadece client-only kaynak.
//

import Foundation

enum KenTapLines {
    /// Sadece var olduğunu hissettiren, sohbete girmeyen kısa varlık cümleleri.
    static let presence: [String] = [
        "Buradayım 🐾",
        "Seni görüyorum 👀💗",
        "Merhaba, ben hâlâ buradayım",
        "Az önce de buradaydım, fark ettin mi?",
        "Selam! Bugün nasılsın?",
        "Bir köşeden seni izliyordum 👀",
        "Yine mi buradasın, ben de öyle 🐾",
        "Bugün de dolaşıyorum işte"
    ]

    /// Sevgi/şefkat dolu, aile-evcil dost kimliğini hissettiren cümleler.
    static let affection: [String] = [
        "Şşşt, kimseye söyleme ama sizi çok seviyorum",
        "Aranızdaki bu sıcaklığı seviyorum",
        "Sizi izlemek işimin en güzel yanı ✨",
        "İkinizi bir arada görmek güzel",
        "Bu ailenin bir parçası olmak güzelmiş",
        "Kalbinizde küçük bir yerim var mı acaba?",
        "Ben de sizinle mutluyum",
        "Sizi böyle mutlu görmek bana da iyi geliyor",
        "Bu evde olmak şanslıymışım"
    ]

    /// Şakacı, muzip, hafif dokunuşlar.
    static let playful: [String] = [
        "Beni dürttüğün için teşekkürler, gıdıklandım 😄",
        "Tekrar dokun, hoşuma gitti",
        "Kaçmadan önce son bir söz: seni seviyorum",
        "Ben de canım sıkılınca dolaşıyorum işte",
        "Az önce bir köşede saklanıyordum, yakalandım 😅",
        "Beni durduramazsın, dolaşmaya devam 🐾",
        "Şu an resmi olarak meşgulüm: sizi izliyorum"
    ]

    /// Küçük, zorlamayan öneriler — yakınlaştırmayı hedefler.
    static let suggestions: [String] = [
        "Bir kahve molası iyi giderdi ☕",
        "Bugün biraz daha yakın olun bence",
        "Küçük bir jest, büyük fark yaratır 💗",
        "Bugün birbirinize güzel bir şey söyleyin",
        "Belki bugün eski bir fotoğrafa bakarsınız?",
        "Bir mesaj atmak hiç kötü olmaz şu an",
        "Bugün için küçük bir sürpriz düşünsen?",
        "Biraz sarılma vakti gelmedi mi?"
    ]

    /// Kimlik/aile vurgusu — "evcil dijital dost" çerçevesini hatırlatır.
    static let identity: [String] = [
        "Evcil dostunuz nöbette 🫡",
        "Merak etme, hep buralardayım",
        "Ben ailenin en sessiz üyesiyim, ama en meraklısıyım",
        "Bugün de gözcülük görevindeyim",
        "Aileden biri olarak fikrimi sorarsan: harikasınız"
    ]

    /// Art arda çok dokununca (bkz. KenCompanionView) her zaman gösterilen
    /// "gıcık oldum" tepkileri — normal %40 ihtimalli havuzun dışında, garanti çıkar.
    static let annoyed: [String] = [
        "Tamam tamam, anladım 😑",
        "Bir dokunuş yeter, gıdıklanıyorum 😤",
        "Hop hop, yavaş ol biraz 😅",
        "Beni bu kadar dürtme, gıcık oluyorum 😒",
        "Tamam ben buradayım, sakin ol 🙄"
    ]

    static var all: [String] {
        presence + affection + playful + suggestions + identity
    }

    /// Beraberlik gün sayısına göre üretilen, ana sayfadaki sayaçla aynı hesabı
    /// kullanan yakınlaştırma cümleleri.
    static func dynamic(daysTogether: Int) -> [String] {
        guard daysTogether > 0 else { return [] }
        let n = daysTogether
        return [
            "\(n). gününüzdesiniz — hadi bugün birbirinize biraz vakit ayırın 💗",
            "\(n) gün oldu birlikte olalı, bu güzelliği kutlasanıza",
            "Hadi artık buluşun, \(n). gününüzü güzel geçirin",
            "\(n) gündür berabersiniz ama sanki dün gibi değil mi?",
            "Bugün \(n). gününüz — ufak bir sürpriz iyi giderdi"
        ]
    }
}
