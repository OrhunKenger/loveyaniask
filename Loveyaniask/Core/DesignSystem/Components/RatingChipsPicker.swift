//
//  RatingChipsPicker.swift
//  Loveyaniask
//
//  10 üzerinden puan seçimi: 1-10 arası numaralı çipler, yatayda kaydırılır.
//  10 yıldız ikonu küçük/sıkışık dururdu; sayı çipleri hem net hem tıklaması kolay.
//  Mekanlar ve Kütüphane'de ortak kullanılır.
//

import SwiftUI

struct RatingChipsPicker: View {
    let current: Int
    var onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(1...10, id: \.self) { value in
                    let selected = value == current
                    Text("\(value)")
                        .font(.subheadline.weight(selected ? .bold : .regular))
                        .foregroundStyle(selected ? .white : AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle().fill(selected ? AppColors.primary : AppColors.glassFill)
                        )
                        .overlay(
                            Circle().stroke(selected ? Color.clear : AppColors.glassStroke, lineWidth: 1)
                        )
                        .onTapGesture {
                            onSelect(value)
                        }
                }
            }
        }
    }
}
