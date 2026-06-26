//
//  AddQuickNoteSheet.swift
//  Loveyaniask
//
//  Hızlı not ekleme.
//

import SwiftUI

struct AddQuickNoteSheet: View {
    let viewModel: QuickNotesViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                Text("Unutmamak istediğin bir şey")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Aklındaki...", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(AppSpacing.md)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer()
            }
            .padding(AppSpacing.md)
            .navigationTitle("Hızlı Not")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        viewModel.add(text)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
