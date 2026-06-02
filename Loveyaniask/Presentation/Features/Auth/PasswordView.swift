//
//  PasswordView.swift
//  Loveyaniask
//
//  Şifre ekranı: ilk açılışta "oluştur", sonrasında "gir".
//

import SwiftUI

struct PasswordView: View {
    let viewModel: AuthViewModel
    let profile: UserProfile

    @State private var password = ""
    @State private var confirm = ""

    private var isCreating: Bool { viewModel.isCreatingPassword() }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                header

                VStack(spacing: AppSpacing.md) {
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if isCreating {
                        SecureField("Şifre (tekrar)", text: $confirm)
                            .textFieldStyle(.roundedBorder)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button(action: submit) {
                    Text(isCreating ? "Şifre Oluştur" : "Giriş Yap")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(password.isEmpty)

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
                    .fill(
                        LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Text(profile.initials)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            Text("Merhaba \(profile.firstName)")
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)

            Text(isCreating ? "İlk girişin — bir şifre belirle" : "Şifreni gir")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, AppSpacing.xxl)
    }

    private func submit() {
        if isCreating {
            viewModel.createPassword(password, confirm: confirm)
        } else {
            viewModel.submitPassword(password)
        }
    }
}
