//
//  LoginView.swift
//  Loveyaniask
//
//  Profil seçim ekranı: Orhun ya da Şevval. Seçilen kişi "Ben" olur.
//  Koyu · romantik tema: gül parıltılı zemin + cam profil kartları.
//

import SwiftUI

struct LoginView: View {
    var onSelect: (UserProfile) -> Void

    var body: some View {
        ZStack {
            GlowBackground()

            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(AppColors.accentGradient)
                        .shadow(color: AppColors.primary.opacity(0.5), radius: 16, y: 4)
                    Text("Kim giriş yapıyor?")
                        .font(AppTypography.screenTitle)
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
                    .fill(AppColors.accentGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 10, y: 4)
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
        .glassCard()
    }
}
