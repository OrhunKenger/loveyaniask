//
//  ChangePasswordSheet.swift
//  Loveyaniask
//
//  Uygulama içinden şifre değiştirme (girili kullanıcı için).
//

import SwiftUI

struct ChangePasswordSheet: View {
    let viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var confirm = ""
    @State private var error: String?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                GlowBackground()

                VStack(spacing: AppSpacing.md) {
                    Text("Yeni bir şifre belirle")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    field("Yeni şifre", text: $newPassword)
                    field("Yeni şifre (tekrar)", text: $confirm)

                    if let error {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PrimaryButton(
                        title: "Kaydet",
                        isLoading: isSaving,
                        isEnabled: !newPassword.isEmpty && !confirm.isEmpty,
                        action: save
                    )

                    Spacer()
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("Şifre Değiştir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
            }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .textFieldStyle(.plain)
            .foregroundStyle(AppColors.textPrimary)
            .padding(AppSpacing.md)
            .background(AppColors.glassFill)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.glassStroke, lineWidth: 1)
            )
    }

    private func save() {
        guard newPassword == confirm else {
            error = "Şifreler eşleşmiyor"
            return
        }
        error = nil
        isSaving = true
        Task {
            let result = await viewModel.changePassword(newPassword)
            isSaving = false
            if let result {
                error = result
            } else {
                dismiss()
            }
        }
    }
}
