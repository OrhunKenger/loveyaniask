//
//  AppColors.swift
//  Loveyaniask
//
//  Uygulamanın renk paleti tek yerden yönetilir.
//  Tema: lacivert / siyah / beyaz tonları — premium ve sade.
//

import SwiftUI

enum AppColors {
    /// Ana vurgu rengi — derin lacivert.
    static let primary = Color(hex: "1F2D50")
    /// İkincil vurgu — neredeyse siyah lacivert (gradyanlar için).
    static let secondary = Color(hex: "0B1220")
    /// Ekran arka planı — çok açık gri/beyaz.
    static let background = Color(hex: "F4F6FA")
    /// Kart / yüzey rengi.
    static let surface = Color(hex: "FFFFFF")
    /// Ana metin rengi — koyu siyah.
    static let textPrimary = Color(hex: "0E141B")
    /// İkincil / soluk metin.
    static let textSecondary = Color(hex: "6B7480")

    // MARK: - Regl takvimi renkleri
    /// Regl günleri.
    static let period = Color(hex: "C75B6A")
    /// Doğurgan (fertile) pencere.
    static let fertile = Color(hex: "8FA8C9")
    /// Yumurtlama (ovulation) günü.
    static let ovulation = Color(hex: "3E5C99")
}
