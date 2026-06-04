//
//  AddJarNoteSheet.swift
//  Loveyaniask
//
//  Kavanoza not yazma.
//

import SwiftUI

struct AddJarNoteSheet: View {
    let viewModel: JarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                Text("İçinden geçenleri yaz")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Bir şeyler yaz...", text: $text, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(AppSpacing.md)
                    .background(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer()
            }
            .padding(AppSpacing.md)
            .navigationTitle("Kavanoza Not")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kavanoza At") {
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
