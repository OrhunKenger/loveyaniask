//
//  PasswordView.swift
//  Loveyaniask
//
//  Şifre ekranı: seçilen profil için Firebase'e giriş yapar.
//  Başarılı girişten sonra oturum cihazda kalıcı kalır (bir daha sorulmaz).
//

import SwiftUI

struct PasswordView: View {
    let viewModel: AuthViewModel
    let profile: UserProfile

    @State private var password = ""

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                header

                VStack(spacing: AppSpacing.md) {
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.go)
                        .onSubmit(submit)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button(action: submit) {
                    Group {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Giriş Yap")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(password.isEmpty || viewModel.isSubmitting)

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
