//
//  PasswordView.swift
//  Loveyaniask
//
//  Şifre ekranı: seçilen profil için Firebase'e giriş yapar.
//  Koyu · romantik tema.
//

import SwiftUI

struct PasswordView: View {
    let viewModel: AuthViewModel
    let profile: UserProfile

    @State private var password = ""

    var body: some View {
        ZStack {
            GlowBackground()

            VStack(spacing: AppSpacing.lg) {
                header

                VStack(spacing: AppSpacing.md) {
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(.plain)
                        .foregroundStyle(AppColors.textPrimary)
                        .submitLabel(.go)
                        .onSubmit(submit)
                        .padding(AppSpacing.md)
                        .background(AppColors.glassFill)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppColors.glassStroke, lineWidth: 1)
                        )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                PrimaryButton(
                    title: "Giriş Yap",
                    isLoading: viewModel.isSubmitting,
                    isEnabled: !password.isEmpty,
                    action: submit
                )

                Button("← Profil değiştir") {
                    viewModel.backToProfiles()
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
    }

    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.accentGradient)
                    .frame(width: 76, height: 76)
                    .shadow(color: AppColors.primary.opacity(0.45), radius: 14, y: 5)
                Text(profile.initials)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            Text("Merhaba \(profile.firstName)")
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text("Şifreni gir")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, AppSpacing.xxl)
    }

    private func submit() {
        guard !password.isEmpty, !viewModel.isSubmitting else { return }
        Task { await viewModel.submitPassword(password) }
    }
}
