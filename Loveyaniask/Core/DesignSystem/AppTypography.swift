//
//  AppTypography.swift
//  Loveyaniask
//
//  Tutarlı tipografi ölçeği (sistem fontu — asset gerektirmez).
//  Büyük başlıklarda .rounded = sıcak/zarif his.
//

import SwiftUI

enum AppTypography {
    static let screenTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let sectionTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let cardTitle = Font.system(size: 16, weight: .semibold)
    static let body = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
    static let number = Font.system(size: 32, weight: .bold, design: .rounded)
}
