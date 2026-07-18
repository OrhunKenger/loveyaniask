//
//  CyclePhase.swift
//  Loveyaniask
//
//  Döngünün 6 fazı (gerçek regl uygulamalarındaki tıbbi model). İçerik motoru
//  (mesaj + ipucu) bu fazlara göre çeşitlenir.
//
//  Regl → Folikküler → Doğurgan → Yumurtlama → Luteal → PMS
//

import SwiftUI

enum CyclePhase: String, CaseIterable, Identifiable {
    case menstrual    // regl günleri
    case follicular   // regl sonrası, doğurganlık öncesi (enerji yükselir)
    case fertile      // doğurgan pencere (yumurtlama çevresi)
    case ovulation    // yumurtlama günü
    case luteal       // yumurtlama sonrası sakinleşme
    case pms          // regl öncesi hassas dönem

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .menstrual: return "🩸"
        case .follicular: return "🌱"
        case .fertile: return "🌼"
        case .ovulation: return "🥚"
        case .luteal: return "🌙"
        case .pms: return "💧"
        }
    }

    /// Kısa ad (rozet/etiket için).
    var name: String {
        switch self {
        case .menstrual: return "Regl"
        case .follicular: return "Folikküler"
        case .fertile: return "Doğurgan"
        case .ovulation: return "Yumurtlama"
        case .luteal: return "Luteal"
        case .pms: return "PMS"
        }
    }

    /// Üst karttaki durum cümlesi.
    var statusText: String {
        switch self {
        case .menstrual: return "Regl dönemindesin"
        case .follicular: return "Enerjin yükseliyor"
        case .fertile: return "Doğurgan dönem"
        case .ovulation: return "Yumurtlama günü"
        case .luteal: return "Luteal faz"
        case .pms: return "PMS dönemi"
        }
    }

    /// Fazın aksan rengi — sayfa bu rengi hisseder (ışıltı, vurgular).
    var accent: Color {
        switch self {
        case .menstrual: return AppColors.period      // gül
        case .follicular: return AppColors.gold       // altın
        case .fertile: return AppColors.fertile       // mavi
        case .ovulation: return AppColors.ovulation   // mor
        case .luteal: return AppColors.secondary      // magenta
        case .pms: return AppColors.primary           // pembe
        }
    }
}
