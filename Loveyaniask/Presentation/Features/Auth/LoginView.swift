//
//  LoginView.swift
//  Loveyaniask
//
//  Profil seçim ekranı: Orhun ya da Şevval. Seçilen kişi "Ben" olur.
//

import SwiftUI

struct LoginView: View {
    var onSelect: (UserProfile) -> Void

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.primary)
                    Text("Kim giriş yapıyor?")
                        .font(.title2.bold())
                        .foregroundStyle(AppColors.textPrimary)
                }

                VStack(spacing: AppSpacing.md) {
                    ForEach(UserProfile.allCases) { profile in
                        Button {
                            onSelect(profile)
                        } label: {
                            profileCard(profile)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
    }

    private func profileCard(_ profile: UserProfile) -> some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: profile == .sevval
                                ? [AppColors.primary, AppColors.secondary]
                                : [AppColors.secondary, AppColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                Text(profile.initials)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.fullName)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Profilini seç")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}
