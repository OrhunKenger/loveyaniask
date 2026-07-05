//
//  SectionHeader.swift
//  Loveyaniask
//
//  Tutarlı bölüm başlığı: başlık + opsiyonel "+" ekle butonu.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var onAdd: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            if let onAdd {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }
        }
    }
}
