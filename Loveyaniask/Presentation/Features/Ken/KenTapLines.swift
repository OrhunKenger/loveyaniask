//
//  KenTapLines.swift
//  Loveyaniask
//
//  Ken'e dokununca çıkabilecek, kod içinde sabit (AI üretmeyen) cümle havuzu.
//  Kategorilere ayrılmış statik içerik + duruma göre üretilen dinamik satırlar
//  (gün sayısı, dönüm günü, özlem, yaklaşan özel gün). Hangi kategorinin ne
//  ağırlıkta karışacağına KenLineSelector karar verir; bulut tarafının ürettiği
//  taze satırlar (KenCompanion.cloudLines) da orada havuza katılır.
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
        "Şu an resmi olarak meşgulüm: sizi izliyorum",
        "Kuyruğuma dikkat, ona da dokunma 😌"
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

    /// Sabah saatlerinde (06-10) öne çıkan cümleler.
    static let morning: [String] = [
        "Günaydın ☀️ Bugün güzel geçsin",
        "Yeni bir gün, yeni bir sizsiniz 💗",
        "Gerinip kalktım, siz de kalkın hadi",
        "Günaydın! İlk mesajı kim atacak?",
        "Sabah sabah aklıma siz geldiniz 🐾",
        "Bugüne güzel bir şey söyleyerek başlayın bence"
    ]

    /// Gece geç saatte (22-06) öne çıkan cümleler.
    static let night: [String] = [
        "Geç oldu, biraz dinlenin 🌙",
        "Işıkları kısıyorum, iyi geceler 💗",
        "Uyumadan önce birbirinize iyi geceler deyin",
        "Gece sessizliği güzel, ama siz daha güzelsiniz",
        "Ben de uykumu alayım, yarın görüşürüz 🐾",
        "Bu saatte hâlâ ayakta mısınız? Yarın yorgun olursunuz"
    ]

    /// Uyuklarken mırıldandıkları.
    static let sleepy: [String] = [
        "Zzz… buradayım, sadece gözlerim kapalı 😴",
        "Bir kestireyim, siz devam edin",
        "Rüyamda da sizi gördüm sanırım",
        "Uyandırma… tamam uyandım 🥱"
    ]

    /// Ruh hali zor tarafa kaydığında öne çıkan şefkatli cümleler.
    /// Neden hissedildiğine dair ASLA tahmin yürütmez, sadece yanında olur.
    static let comfort: [String] = [
        "Bugün biraz yavaş gidiyoruz galiba… ben buradayım 🐾",
        "Bir şey söylemene gerek yok, yanındayım",
        "Sarılmak iyi gelir bence 💗",
        "Bugün kendinize biraz nazik davranın",
        "Her gün iyi olmak zorunda değil",
        "Sesim çıkmasın, sadece burada oturuyorum",
        "Birbirinize sıkı sıkı sarılın bugün",
        "Geçer. Ben de o zamana kadar buradayım"
    ]

    /// Kutlama davranışında (dönüm günü) söylenebilecek genel coşku cümleleri.
    static let celebration: [String] = [
        "Bugün kutlama var, ben başlıyorum 🎉",
        "Zıplamamı mazur görün, çok sevindim 💗",
        "Bu güzel günü es geçmeyelim!",
        "Alkışlıyorum, kollarım varsa tabii 🐾",
        "Böyle günler için varım ben ✨"
    ]

    /// Art arda çok dokununca (bkz. KenStage) her zaman gösterilen
    /// "gıcık oldum" tepkileri — normal havuzun dışında, garanti çıkar.
    static let annoyed: [String] = [
        "Tamam tamam, anladım 😑",
        "Bir dokunuş yeter, gıdıklanıyorum 😤",
        "Hop hop, yavaş ol biraz 😅",
        "Beni bu kadar dürtme, gıcık oluyorum 😒",
        "Tamam ben buradayım, sakin ol 🙄"
    ]

    /// Havaya fırlatılıp yere çakıldıktan sonra söylenenler. Kızgın ama
    /// kırıcı değil — Ken size sitem eder, sizi suçlamaz.
    static let thrown: [String] = [
        "Ayy! Ne yapıyorsun sen 😤",
        "Bir daha yaparsan küserim bak",
        "Uçmayı sevmiyorum, haberin olsun 😒",
        "Kafamı çarptım… sağ ol",
        "Tamam, oyun bu, anladım. Ama yavaş 😑",
        "Beni eşya sandın galiba"
    ]

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

    /// Yuvarlak bir beraberlik gününde (100, 200, 365...) söylenenler.
    static func milestone(days: Int) -> [String] {
        guard days > 0 else { return celebration }
        let years = days / 365
        var lines = [
            "\(days). gün! Bunu kutlamadan geçmeyelim 🎉",
            "Bugün \(days) gününüz — ben şimdiden heyecanlandım 💗",
            "\(days) gün… Sayıyorum, gerçekten sayıyorum 🐾",
            "\(days) gündür berabersiniz. Bunu bir kutlayın bence ✨"
        ]
        if years >= 1, days % 365 == 0 {
            lines.append("\(years) yıl oldu! Yıl dönümünüz kutlu olsun 🎉")
        }
        return lines
    }

    /// Uygulama günlerce açılmadıysa dönüşte söylenenler.
    static func missed(days: Int) -> [String] {
        let n = max(days, 2)
        return [
            "\(n) gündür yoktunuz… Özledim 🐾",
            "Geldiniz! Ben burada bekliyordum 💗",
            "\(n) gün boyunca ekrana baktım durdum, neyse ki döndünüz",
            "Sizi merak ettim. İyi ki geldiniz",
            "Yokluğunuzda burası çok sessizdi"
        ]
    }

    /// Yaklaşan bir özel gün varsa hatırlatma — tarihi zorlamadan, tatlı tonda.
    static func upcoming(title: String, daysRemaining: Int) -> [String] {
        let when: String
        switch daysRemaining {
        case ..<0: return []
        case 0: when = "bugün"
        case 1: when = "yarın"
        default: when = "\(daysRemaining) gün sonra"
        }
        return [
            "\(title) \(when) — haberin olsun 🐾",
            "\(when) \(title) var, ufak bir sürpriz düşünsen?",
            "Unutma: \(title), \(when) 💗",
            "\(title) yaklaşıyor (\(when)) — hazırlık var mı? ✨"
        ]
    }
}
