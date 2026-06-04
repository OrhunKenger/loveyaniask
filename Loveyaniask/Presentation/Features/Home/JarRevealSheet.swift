//
//  JarRevealSheet.swift
//  Loveyaniask
//
//  Kavanoz açıldığında notları TEK TEK çekme ekranı.
//  Her dokunuşta bir sonraki kâğıt kavanozdan süzülerek gelir; sonunda
//  "Yeni aya başla" ile kavanoz boşalır ve döngü yeniden başlar.
//

import SwiftUI

struct JarRevealSheet: View {
    let viewModel: JarViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var index = 0
    @State private var showingConfirm = false

    private var notes: [JarNote] { viewModel.sortedNotes }
    private var isLast: Bool { index >= notes.count - 1 }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                if notes.isEmpty {
                    emptyState
                } else {
                    Text("\(index + 1) / \(notes.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, AppSpacing.sm)

                    Spacer(minLength: 0)

                    paperCard(notes[index])
                        .id(index)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.6)
                                .combined(with: .opacity)
                                .combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .scale(scale: 0.9))
                        ))
                        .onTapGesture { advance() }

                    Spacer(minLength: 0)

                    controls
                }
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Kavanoz 🫙")
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

    // MARK: - Alt kontroller

    @ViewBuilder
    private var controls: some View {
        if isLast {
            VStack(spacing: AppSpacing.sm) {
                Text("Hepsi bu kadar 💖")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.primary)

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
            }
        } else {
            Button {
                advance()
            } label: {
                Label("Sonraki kâğıt", systemImage: "hand.tap.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer()
            Text("Bu ay hiç not atılmamış 🤍")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            Button(role: .destructive) {
                showingConfirm = true
            } label: {
                Label("Yeni aya başla", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.primary)
            Spacer()
        }
    }

    // MARK: - Kâğıt kartı

    private func paperCard(_ note: JarNote) -> some View {
        let angle = Double((index % 5) - 2) * 1.6   // hafif el ile çekilmiş hissi

        return VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text(note.text)
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundStyle(Color(hex: "3A2E1E"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("— \(viewModel.authorName(note))")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColors.primary)
                    Text(viewModel.dateText(note))
                        .font(.caption)
                        .foregroundStyle(Color(hex: "8A7A5C"))
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color(hex: "FDF6E3"), Color(hex: "F3E7C9")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .rotationEffect(.degrees(angle))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        .padding(.horizontal, AppSpacing.sm)
    }

    private func advance() {
        guard !isLast else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            index += 1
        }
    }
}
