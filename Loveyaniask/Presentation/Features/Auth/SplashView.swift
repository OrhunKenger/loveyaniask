//
//  SplashView.swift
//  Loveyaniask
//
//  Açılış ekranı: logo + kalp animasyonu, sonra giriş ekranına geçer.
//

import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(.white)
                Text("loveyaniask")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8)) {
                scale = 1
                opacity = 1
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.6))
            onFinish()
        }
    }
}
