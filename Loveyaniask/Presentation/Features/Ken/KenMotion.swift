//
//  KenMotion.swift
//  Loveyaniask
//
//  Ken'in hareket motoru. Her davranış için, geçen sürenin fonksiyonu olarak
//  tek bir kare (KenFrame) üretir.
//
//  Neden böyle: SwiftUI'ın repeatForever animasyonları tek frekanslı ve sabit
//  genlikli olduğu için mekanik duruyordu; ayrıca her davranış değişiminde
//  view'ı sıfırlamak gerekiyordu. Burada hareket sürekli zamanın fonksiyonu
//  olduğu için birden fazla ritim üst üste binebiliyor (nefes + salınım + adım),
//  davranış geçişi de iki karenin harmanlanmasıyla kesintisiz oluyor
//  (bkz. KenCharacterView).
//

import Foundation
import CoreGraphics

/// Ken'in tek bir andaki tüm gövde/yüz sayıları.
struct KenFrame {
    /// Uzuv açıları (derece): 0 = aşağı, 90 = sağa, -90 = sola, 180 = yukarı.
    var armLeft: Double = -20
    var armRight: Double = 20
    var legLeft: Double = -12
    var legRight: Double = 12
    /// Gövde eğimi (derece, pozitif = saat yönü).
    var lean: Double = 0
    /// Dikey ofset, gövde yüksekliğinin oranı (negatif = yukarı).
    var lift: CGFloat = 0
    /// Çömelme (+) / uzama (−) miktarı.
    var squash: CGFloat = 0
    /// Kuyruğun kıvrımı: -1 (aşağı sarkık) ... 1 (yukarı kalkık).
    var tail: Double = 0
    /// Göz bebeklerinin bakış yönü, -1...1.
    var gazeX: CGFloat = 0
    var gazeY: CGFloat = 0
    /// İfadedeki kısılmanın üstüne binen göz kapağı çarpanı (0 kapalı ... 1 açık).
    var eyeOpen: CGFloat = 1
    /// Ağız açıklığı: 0 çizgi, 1 tam açık (esneme/kahkaha).
    var mouthOpen: CGFloat = 0

    /// İki kareyi harmanlar — davranış geçişlerinde eski pozdan yenisine
    /// yumuşak akış bunun sayesinde oluyor.
    static func blend(_ a: KenFrame, _ b: KenFrame, _ progress: Double) -> KenFrame {
        let t = min(max(progress, 0), 1)
        func m(_ x: Double, _ y: Double) -> Double { x + (y - x) * t }
        func c(_ x: CGFloat, _ y: CGFloat) -> CGFloat { x + (y - x) * CGFloat(t) }
        var f = KenFrame()
        f.armLeft = m(a.armLeft, b.armLeft)
        f.armRight = m(a.armRight, b.armRight)
        f.legLeft = m(a.legLeft, b.legLeft)
        f.legRight = m(a.legRight, b.legRight)
        f.lean = m(a.lean, b.lean)
        f.lift = c(a.lift, b.lift)
        f.squash = c(a.squash, b.squash)
        f.tail = m(a.tail, b.tail)
        f.gazeX = c(a.gazeX, b.gazeX)
        f.gazeY = c(a.gazeY, b.gazeY)
        f.eyeOpen = c(a.eyeOpen, b.eyeOpen)
        f.mouthOpen = c(a.mouthOpen, b.mouthOpen)
        return f
    }
}

enum KenMotion {
    /// Davranış geçişinin harmanlanma süresi (saniye).
    static let transition: Double = 0.5

    // MARK: - Kare üretimi

    /// `elapsed`: davranış başladığından beri geçen süre (saniye).
    static func frame(for behavior: KenBehavior, elapsed e: Double) -> KenFrame {
        switch behavior {
        case .peek: peek(e)
        case .dangle: dangle(e)
        case .wander: wander(e)
        case .sit: sit(e)
        case .stretch: stretch(e)
        case .snooze: snooze(e)
        case .bounce: bounce(e, period: 0.78, armLift: 90)
        case .celebrate: celebrate(e)
        case .greet: greet(e)
        case .introduce: introduce(e)
        case .miss: miss(e)
        case .held: held(e)
        case .dizzy: dizzy(e)
        case .grumble: grumble(e)
        }
    }

    /// Göz kırpma: davranıştan bağımsız, kendi ritminde. Zamanın saf fonksiyonu
    /// olması için aralık, kare indeksinden türetilen sabit bir "rastgelelikle"
    /// kaydırılıyor — böylece düzenli tik tak gibi durmuyor ama state tutmuyoruz.
    static func blink(at t: Double) -> CGFloat {
        let period = 3.1
        let index = (t / period).rounded(.down)
        let jitter = fract(sin(index * 12.9898) * 43758.5453) * 1.7
        let start = index * period + jitter
        let d = t - start
        guard d >= 0, d < 0.15 else { return 0 }
        return CGFloat(sin(d / 0.15 * .pi))
    }

    // MARK: - Davranışlar

    /// Kenardan içeri uzanıp bakar; yavaşça el sallar.
    private static func peek(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let br = wave(e, 3.4)
        f.lean = -6 + 1.6 * wave(e, 2.7)
        f.armLeft = -58 + 16 * wave(e, 1.25)
        f.armRight = 16 + 4 * br
        f.legLeft = -10
        f.legRight = 10
        f.lift = -0.008 * CGFloat(br)
        f.squash = 0.016 * CGFloat(br)
        f.tail = 0.35 + 0.3 * wave(e, 1.9)
        f.gazeX = -0.5
        f.gazeY = 0.05
        return f
    }

    /// Yukarıdaki ipe tutunmuş, sarkaç gibi salınır.
    private static func dangle(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let sway = wave(e, 2.1)
        let lag = wave(e, 2.1, phase: -0.55)
        f.lean = 9 * sway
        f.armLeft = -168
        f.armRight = 168
        f.legLeft = -14 + 17 * lag
        f.legRight = 14 + 17 * lag
        f.lift = -0.01 * CGFloat(wave(e, 1.05))
        f.tail = 0.5 * lag
        f.gazeX = CGFloat(0.35 * sway)
        f.gazeY = 0.3
        return f
    }

    /// Yürüme: bacak/kol karşılıklı, gövde adım ritminde hafifçe zıplayıp öne eğiliyor.
    private static func wander(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let step = 2 * Double.pi * e / 0.64
        f.legLeft = 30 * sin(step)
        f.legRight = 30 * sin(step + .pi)
        f.armLeft = -18 + 24 * sin(step + .pi)
        f.armRight = 18 + 24 * sin(step)
        f.lift = -0.022 * CGFloat(abs(sin(step)))
        f.squash = 0.035 * CGFloat(max(0, -sin(2 * step)))
        f.lean = 5 + 2 * sin(step)
        f.tail = 0.55 * sin(step) + 0.2
        f.gazeX = 0.45
        return f
    }

    /// Oturuş: bacaklar önde, derin nefes, gözler tembel tembel etrafta dolaşıyor.
    private static func sit(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let br = wave(e, 3.9)
        f.legLeft = -62 + 4 * wave(e, 3.1)
        f.legRight = 62 - 4 * wave(e, 3.1)
        f.armLeft = -34 + 3 * br
        f.armRight = 34 - 3 * br
        f.lift = 0.055 - 0.008 * CGFloat(br)
        f.squash = 0.05 + 0.03 * CGFloat(br)
        f.lean = 2 * wave(e, 5.1)
        f.tail = 0.45 * wave(e, 2.4)
        f.gazeX = CGFloat(0.35 * wave(e, 5.7))
        f.gazeY = CGFloat(0.15 * wave(e, 3.3, phase: 1))
        return f
    }

    /// Esneme: kollar yukarı uzanır, gövde uzar, arada bir esner (ağız açılır,
    /// gözler kısılır), sonra gevşeyip normal nefes ritmine döner.
    private static func stretch(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let rise = ease(e / 0.85)
        let release = ease((e - 1.5) / 0.8)
        let up = rise * (1 - release)
        let yawn = bump(e, center: 0.75, width: 0.55)
        let br = wave(e, 3.6)
        f.armLeft = -20 - 152 * up
        f.armRight = 20 + 152 * up
        f.legLeft = -12 - 6 * up
        f.legRight = 12 + 6 * up
        f.squash = CGFloat(-0.16 * up) + 0.02 * CGFloat(br) * CGFloat(release)
        f.lift = CGFloat(-0.05 * up)
        f.lean = 3 * wave(e, 2.3)
        f.tail = 0.2 + 0.8 * up
        f.mouthOpen = CGFloat(0.9 * yawn)
        f.eyeOpen = CGFloat(1 - 0.8 * yawn)
        f.gazeY = -0.25
        return f
    }

    /// Uyuklama: yere yayılmış, çok yavaş ve derin nefes, gözler kapalı.
    private static func snooze(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let br = wave(e, 5.2)
        f.legLeft = -48
        f.legRight = 48
        f.armLeft = -14
        f.armRight = 14
        f.lean = 9
        f.lift = 0.04
        f.squash = 0.11 + 0.05 * CGFloat(br)
        f.tail = 0.2 * wave(e, 4.4) - 0.15
        f.eyeOpen = 0.05
        f.mouthOpen = CGFloat(0.12 + 0.05 * br)
        return f
    }

    /// Zıplama — önce çömelme (anticipation), sonra havada uzama, inişte çöküş.
    private static func bounce(_ e: Double, period: Double, armLift: Double) -> KenFrame {
        var f = KenFrame()
        let u = fract(e / period)
        var height = 0.0   // havadaki yükseklik, 0...1
        var crouch = 0.0   // yerdeki çömelme, 0...1
        var squash = 0.0

        if u < 0.22 {
            crouch = ease(u / 0.22)
            squash = 0.24 * crouch
        } else if u < 0.78 {
            let a = (u - 0.22) / 0.56
            height = sin(a * .pi)
            squash = -0.12 * height
        } else {
            let a = ease((u - 0.78) / 0.22)
            squash = 0.2 * (1 - a)
        }

        f.lift = CGFloat(-0.3 * height + 0.035 * crouch)
        f.squash = CGFloat(squash)
        f.armLeft = -20 - armLift * height + 14 * crouch
        f.armRight = 20 + armLift * height - 14 * crouch
        f.legLeft = -12 - 18 * height
        f.legRight = 12 + 18 * height
        f.lean = 4 * wave(e, 0.9)
        f.tail = 0.4 + 0.6 * wave(e, 0.26)
        f.mouthOpen = CGFloat(0.35 * height)
        f.gazeY = CGFloat(-0.2 * height)
        return f
    }

    /// Kutlama: zıplamanın daha coşkulusu — kollar tam yukarı, kuyruk hızlı.
    private static func celebrate(_ e: Double) -> KenFrame {
        var f = bounce(e, period: 0.62, armLift: 150)
        f.tail = 0.5 + 0.5 * wave(e, 0.18)
        f.lean = 7 * wave(e, 0.62)
        f.mouthOpen = max(f.mouthOpen, 0.3)
        return f
    }

    /// Selam: hızlı el sallama + hafif sevinç zıplaması.
    private static func greet(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let waveArm = wave(e, 0.42)
        let hop = abs(wave(e, 0.84))
        f.armRight = -92 + 24 * waveArm
        f.armLeft = -22
        f.legLeft = -14 - 4 * hop
        f.legRight = 14 + 4 * hop
        f.lift = CGFloat(-0.035 * hop)
        f.squash = CGFloat(0.03 * (1 - hop))
        f.lean = -4 + 3 * waveArm
        f.tail = 0.5 + 0.45 * wave(e, 0.3)
        f.gazeY = -0.15
        f.mouthOpen = 0.18
        return f
    }

    /// Tanıtım: önce küçük bir reverans, sonra sakin duruş; arada el sallar.
    private static func introduce(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let bow = bump(e, center: 0.55, width: 0.75)
        let br = wave(e, 3.5)
        let hello = e > 1.8 ? bump(e, center: 2.6, width: 0.9) : 0
        f.lean = 10 * bow
        f.squash = CGFloat(0.12 * bow + 0.02 * br)
        f.lift = CGFloat(0.02 * bow - 0.006 * br)
        f.armLeft = -26 - 20 * bow
        f.armRight = 26 + 20 * bow - 110 * hello + 18 * hello * wave(e, 0.4)
        f.legLeft = -14
        f.legRight = 14
        f.tail = 0.3 + 0.35 * wave(e, 1.6)
        f.gazeY = -0.1
        f.mouthOpen = CGFloat(0.15 * hello)
        return f
    }

    /// Özledim: gövde biraz çökük, kollar hafif açık, bakış yukarıda —
    /// sonra sizi fark etmiş gibi tek bir sevinç zıplaması.
    private static func miss(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let br = wave(e, 3.2)
        let hop = bump(e, center: 2.1, width: 0.45)
        f.lean = -4 + 3 * wave(e, 3.6)
        f.armLeft = -46 + 5 * br - 30 * hop
        f.armRight = 46 - 5 * br + 30 * hop
        f.legLeft = -12
        f.legRight = 12
        f.lift = CGFloat(0.045 - 0.006 * br - 0.22 * hop)
        f.squash = CGFloat(0.06 + 0.02 * br - 0.1 * hop)
        f.tail = 0.05 + 0.2 * wave(e, 3.0) + 0.7 * hop
        f.gazeY = -0.38
        f.mouthOpen = CGFloat(0.25 * hop)
        return f
    }

    /// Parmakla tutulmuş / havada: kollar yukarı savrulmuş, bacaklar hızlı
    /// tekme atıyor, gövde hafifçe sallanıyor. Uçarken de aynı poz — çırpınıyor.
    private static func held(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let kick = wave(e, 0.34)
        let kick2 = wave(e, 0.34, phase: .pi)
        f.armLeft = -150 + 18 * wave(e, 0.46)
        f.armRight = 150 - 18 * wave(e, 0.46, phase: 0.7)
        f.legLeft = -26 + 30 * kick
        f.legRight = 26 + 30 * kick2
        f.lean = 5 * wave(e, 0.62)
        f.squash = CGFloat(-0.05 + 0.02 * wave(e, 0.5))
        f.tail = 0.15 + 0.5 * wave(e, 0.4)
        f.eyeOpen = 1
        f.gazeY = -0.2
        f.mouthOpen = CGFloat(0.35 + 0.2 * kick)
        return f
    }

    /// Sert düşüşten sonra: yerde toparlanıyor, gövde sağa sola devriliyor,
    /// gözler süzülmüş, kafası dönüyor.
    private static func dizzy(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let wobble = wave(e, 0.9)
        f.lean = 14 * wobble
        f.armLeft = -70 + 20 * wave(e, 1.1)
        f.armRight = 70 - 20 * wave(e, 1.1, phase: 0.5)
        f.legLeft = -40
        f.legRight = 40
        f.lift = 0.05
        f.squash = CGFloat(0.14 + 0.03 * wave(e, 0.7))
        f.tail = -0.4 + 0.2 * wave(e, 1.4)
        f.eyeOpen = 0.35
        f.gazeX = CGFloat(0.5 * wobble)
        f.mouthOpen = 0.3
        return f
    }

    /// Doğrulup söylenme: dikilmiş, gergin, ayağını yere vuruyor.
    private static func grumble(_ e: Double) -> KenFrame {
        var f = KenFrame()
        let stomp = max(0, wave(e, 0.7))
        f.armLeft = -52
        f.armRight = 52
        f.legLeft = -14
        f.legRight = 14 - 26 * stomp
        f.lean = 2 * wave(e, 0.35)
        f.lift = CGFloat(-0.02 * stomp)
        f.squash = CGFloat(0.05 - 0.04 * stomp)
        f.tail = -0.2 + 0.35 * wave(e, 0.5)
        f.gazeY = -0.1
        f.mouthOpen = CGFloat(0.25 * stomp)
        return f
    }

    // MARK: - Yardımcılar

    private static func wave(_ e: Double, _ period: Double, phase: Double = 0) -> Double {
        sin(2 * .pi * e / period + phase)
    }

    /// 0...1 aralığına kırpılmış yumuşak geçiş eğrisi (smoothstep).
    static func ease(_ x: Double) -> Double {
        let t = min(max(x, 0), 1)
        return t * t * (3 - 2 * t)
    }

    /// `center` etrafında `width` yarıçapında yumuşak bir tepe (0 → 1 → 0).
    private static func bump(_ e: Double, center: Double, width: Double) -> Double {
        let d = (e - center) / width
        guard abs(d) < 1 else { return 0 }
        let c = cos(d * .pi / 2)
        return c * c
    }

    private static func fract(_ x: Double) -> Double { x - x.rounded(.down) }
}
