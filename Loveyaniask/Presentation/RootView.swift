//
//  RootView.swift
//  Loveyaniask
//
//  Uygulamanın kök ekranı. Şimdilik iskeletin/tasarım sisteminin
//  çalıştığını doğrulamak için basit bir karşılama ekranı.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(AppColors.primary)

                Text("loveyaniask")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppColors.textPrimary)

                Text("birlikte, hep birlikte")
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    RootView()
}
