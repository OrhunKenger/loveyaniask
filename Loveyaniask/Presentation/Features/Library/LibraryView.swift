//
//  LibraryView.swift
//  Loveyaniask
//
//  Dijital Kütüphane (film / dizi / kitap). Şimdilik iskelet —
//  gerçek tasarım + TMDB/Google Books araması bir sonraki adımda gelecek.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(AppColors.primary)
                Text("Kütüphane")
                    .font(.title2.bold())
                    .foregroundStyle(AppColors.textPrimary)
                Text("İzlediğimiz, okuduğumuz her şey 📚🎬📺\nÇok yakında burada.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.lg)
        }
    }
}
