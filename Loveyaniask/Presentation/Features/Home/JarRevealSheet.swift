//
//  JarRevealSheet.swift
//  Loveyaniask
//
//  Kavanoz açıldığında bu ayın tüm notlarını okuma ekranı.
//  Okuduktan sonra "Yeni aya başla" ile kavanoz boşalır ve döngü yeniden başlar.
//

import SwiftUI

struct JarRevealSheet: View {
    let viewModel: JarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    Text("Bu ayın notları 🫙")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.top, AppSpacing.sm)

                    if viewModel.sortedNotes.isEmpty {
                        Text("Bu ay hiç not atılmamış.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.top, AppSpacing.lg)
                    } else {
                        ForEach(viewModel.sortedNotes) { note in
                            noteCard(note)
                        }
                    }

                    Button(role: .destructive) {
                        showingConfirm = true
                    } label: {
                        Label("Yeni aya başla (kavanozu boşalt)", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.primary)
                    .padding(.top, AppSpacing.md)
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Kavanoz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .confirmationDialog(
                "Kavanozu boşaltıp yeni aya başlamak istediğine emin misin? Bu notlar silinecek.",
                isPresented: $showingConfirm,
                titleVisibility: .visible
            ) {
                Button("Boşalt ve başla", role: .destructive) {
                    viewModel.startNewCycle()
                    dismiss()
                }
                Button("Vazgeç", role: .cancel) {}
            }
        }
    }

    private func noteCard(_ note: JarNote) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(note.text)
                .font(.body)
                .foregroundStyle(AppColors.textPrimary)
            HStack {
                Text(viewModel.authorName(note))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
                Spacer()
                Text(viewModel.dateText(note))
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FBF3E0"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
