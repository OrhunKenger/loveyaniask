//
//  MemoryJarSection.swift
//  Loveyaniask
//
//  Ana sayfadaki kavanoz kartı: kavanoz + not ekle + (dolunca) oku.
//

import SwiftUI

struct MemoryJarSection: View {
    @Bindable var viewModel: JarViewModel

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Birbirimiz Hakkında 💭")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(viewModel.count)/\(viewModel.capacity)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            MemoryJarView(count: viewModel.count)
                .onTapGesture {
                    if viewModel.count > 0 { viewModel.showingRead = true }
                }

            if viewModel.isFull {
                Text("Kavanoz doldu! 🎉 Aç ve hepsini oku")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)
            } else {
                Text("İçine birbiriniz hakkında düşündüklerinizi atın")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: AppSpacing.md) {
                Button {
                    viewModel.showingAdd = true
                } label: {
                    Label("Not Ekle", systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Button {
                    viewModel.showingRead = true
                } label: {
                    Label("Oku", systemImage: "book")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(viewModel.count == 0)
                .opacity(viewModel.count == 0 ? 0.5 : 1)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        .sheet(isPresented: $viewModel.showingAdd) {
            AddJarNoteSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingRead) {
            JarNotesListSheet(viewModel: viewModel)
        }
    }
}
