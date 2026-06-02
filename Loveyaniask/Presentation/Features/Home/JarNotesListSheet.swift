//
//  JarNotesListSheet.swift
//  Loveyaniask
//
//  Kavanozdaki tüm notları okuma.
//

import SwiftUI

struct JarNotesListSheet: View {
    let viewModel: JarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.sortedNotes) { note in
                        noteCard(note)
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Kavanoz 🫙")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kapat") { dismiss() }
                }
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
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(note)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}
