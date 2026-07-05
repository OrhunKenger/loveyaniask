//
//  AppColors.swift
//  Loveyaniask
//
//  Uygulamanın renk paleti tek yerden yönetilir.
//  Tema: KOYU · romantik · fütüristik — gece moru-siyahı zemin,
//  gül→magenta aksan, soft altın vurgu. (Kütüphane vitrininin diliyle aynı.)
//

import SwiftUI

enum AppColors {
    // MARK: - Aksan (gül → magenta-mor)
    /// Ana vurgu — gül.
    static let primary = Color(hex: "FF6FA5")
    /// İkincil vurgu — magenta-mor (gradyanlar için).
    static let secondary = Color(hex: "B5479B")
    /// Zarif altın vurgu — ince ayraç/detaylar.
    static let gold = Color(hex: "E7C089")

    // MARK: - Koyu zeminler
    /// Ekran arka planı — gece moru-siyahı.
    static let background = Color(hex: "0C0A14")
    /// Biraz yükseltilmiş zemin.
    static let backgroundElevated = Color(hex: "141026")
    /// Kart / yüzey tabanı (koyu).
    static let surface = Color(hex: "191430")

    // MARK: - Cam yüzey (koyu üstüne beyaz overlay — ucuz "glass", canlı blur YOK)
    static let glassFill = Color.white.opacity(0.06)
    static let glassStroke = Color.white.opacity(0.12)

    // MARK: - Metin
    /// Ana metin — neredeyse beyaz.
    static let textPrimary = Color(hex: "F3EFF7")
    /// İkincil / soluk metin — mat lavanta-gri.
    static let textSecondary = Color(hex: "9C93B0")

    // MARK: - Regl takvimi renkleri (koyuya uyarlı)
    static let period = Color(hex: "E86A8A")
    static let fertile = Color(hex: "7FA0D8")
    static let ovulation = Color(hex: "7E6BF0")

    // MARK: - Gradyanlar
    /// Gül → magenta aksan gradyanı (buton, sayaç, vurgular).
    static var accentGradient: LinearGradient {
        LinearGradient(colors: [primary, secondary],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    /// Ekran arka plan gradyanı (gece moru → siyah).
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "1B1030"), Color(hex: "0C0A14"), Color(hex: "060410")],
                       startPoint: .top, endPoint: .bottom)
    }
}
