//
//  QuickNotesSection.swift
//  Loveyaniask
//
//  Ana sayfada (sayacın hemen altında) "Hızlı Not": aklınıza geleni hemen
//  ekleyip unutmamak için ortak, serbest not listesi. En yeni üstte.
//  Silmek için bir nota uzun bas → Sil (Planlar/Özel Günler ile aynı davranış;
//  ana sayfa bir ScrollView olduğundan gerçek "kaydır-sil" List gerektirirdi).
//

import SwiftUI

struct QuickNotesSection: View {
    @Bindable var viewModel: QuickNotesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Hızlı Not")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button {
                    viewModel.showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                }
            }

            if viewModel.notes.isEmpty {
                Text("Aklınıza geleni hemen ekleyin — + ile not bırakın (unutmayın diye)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.notes) { note in
                        noteRow(note)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAdd) {
            AddQuickNoteSheet(viewModel: viewModel)
        }
    }

    private func noteRow(_ note: QuickNote) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "note.text")
                .font(.caption)
                .foregroundStyle(AppColors.primary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 3) {
                Text(note.text)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(viewModel.authorName(note)) · \(viewModel.dateText(note))")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.delete(note)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}
