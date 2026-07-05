//
//  ProfileView.swift
//  Loveyaniask
//
//  İkinizi gösteren şık koyu profil sayfası: her partner için fotoğraflı kart
//  (isim, takma ad, hakkında). Kendi kartını düzenlersin, partnerinkini görürsün.
//

import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    var onSignOut: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                GlowBackground()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        card(for: viewModel.currentUser, isMe: true)
                        card(for: viewModel.partner, isMe: false)

                        Button(role: .destructive) {
                            dismiss()
                            onSignOut()
                        } label: {
                            Label("Çıkış yap", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                                .glassCard(cornerRadius: 16, padding: 0)
                        }
                        .padding(.top, AppSpacing.sm)
                    }
                    .padding(AppSpacing.md)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .sheet(isPresented: $viewModel.showingEdit) {
                EditProfileSheet(viewModel: viewModel)
            }
        }
    }

    private func card(for profile: UserProfile, isMe: Bool) -> some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.accentGradient)
                    .frame(width: 112, height: 112)
                if let img = viewModel.image(for: profile) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 104, height: 104)
                        .clipShape(Circle())
                } else {
                    Text(profile.initials)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .shadow(color: AppColors.primary.opacity(0.4), radius: 16, y: 6)

            VStack(spacing: 3) {
                Text(profile.fullName)
                    .font(.title3.bold())
                    .foregroundStyle(AppColors.textPrimary)
                Text(profile.petName)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.primary)
            }

            let bio = viewModel.bio(for: profile)
            if !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            } else if isMe {
                Text("Kendin hakkında bir şeyler yaz…")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if isMe {
                Button {
                    viewModel.showingEdit = true
                } label: {
                    Label("Düzenle", systemImage: "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .accentGradientBackground(cornerRadius: 12)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 24, padding: AppSpacing.lg)
    }
}
