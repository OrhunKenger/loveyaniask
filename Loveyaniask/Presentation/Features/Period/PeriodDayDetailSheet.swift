//
//  PeriodDayDetailSheet.swift
//  Loveyaniask
//
//  Bir güne dokununca açılır: faz bilgisi + (Şevval için) belirti/not + regl başlangıcı işaretleme.
//

import SwiftUI

struct PeriodDayDetailSheet: View {
    let viewModel: PeriodViewModel
    let date: Date
    let canEdit: Bool

    @Environment(\.dismiss) private var dismiss

    @State private var symptoms: Set<Symptom> = []
    @State private var noteText: String = ""

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: AppSpacing.sm)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    phaseHeader

                    if canEdit {
                        symptomsSection
                        noteSection
                        Button {
                            viewModel.markAsPeriodStart(date)
                            dismiss()
                        } label: {
                            Label("Bu günü regl başlangıcı işaretle", systemImage: "drop.fill")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(AppColors.period)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.period.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    } else {
                        readOnlyNotes
                    }
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle(viewModel.dayTitle(for: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canEdit {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kaydet") {
                            viewModel.saveNote(for: date, symptoms: Array(symptoms), text: noteText)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                } else {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kapat") { dismiss() }
                    }
                }
            }
        }
        .onAppear {
            if let existing = viewModel.note(for: date) {
                symptoms = Set(existing.symptoms)
                noteText = existing.note
            }
        }
    }

    private var phaseHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.phaseText(for: date))
                .font(.title3.bold())
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Belirtiler")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            LazyVGrid(columns: columns, alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Symptom.allCases) { symptom in
                    let selected = symptoms.contains(symptom)
                    Button {
                        if selected { symptoms.remove(symptom) } else { symptoms.insert(symptom) }
                    } label: {
                        HStack(spacing: 4) {
                            Text(symptom.emoji)
                            Text(symptom.label)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selected ? AppColors.primary.opacity(0.15) : Color.black.opacity(0.04))
                        .foregroundStyle(selected ? AppColors.primary : AppColors.textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Not")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            TextField("Bugünle ilgili bir not...", text: $noteText, axis: .vertical)
                .lineLimit(2...4)
                .padding(AppSpacing.sm)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var readOnlyNotes: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let note = viewModel.note(for: date), !note.isEmpty {
                if !note.symptoms.isEmpty {
                    Text("Belirtiler")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(note.symptoms.map { "\($0.emoji) \($0.label)" }.joined(separator: "   "))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
                if !note.note.isEmpty {
                    Text("Not")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(note.note)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                Text("Bu gün için kayıt yok.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
