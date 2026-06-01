//
//  AppColors.swift
//  Loveyaniask
//
//  Uygulamanın renk paleti tek yerden yönetilir.
//  Premium / sıcak bir his için yumuşak gül + krem + koyu eflatun tonları.
//

import SwiftUI

enum AppColors {
    /// Ana vurgu rengi — yumuşak gül.
    static let primary = Color(hex: "E2868D")
    /// İkincil vurgu — koyu eflatun.
    static let secondary = Color(hex: "5B4B8A")
    /// Ekran arka planı — sıcak krem.
    static let background = Color(hex: "FFF7F4")
    /// Kart / yüzey rengi.
    static let surface = Color(hex: "FFFFFF")
    /// Ana metin rengi.
    static let textPrimary = Color(hex: "2D2A32")
    /// İkincil / soluk metin.
    static let textSecondary = Color(hex: "9A9098")
}
