//
//  AddSpecialDaySheet.swift
//  Loveyaniask
//
//  Yeni özel gün ekleme: başlık, emoji, tarih, yıllık tekrar.
//

import SwiftUI

struct AddSpecialDaySheet: View {
    let viewModel: SpecialDaysViewModel
    let editing: SpecialDay?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var emoji: String
    @State private var date: Date
    @State private var repeatsYearly: Bool

    private let emojis = ["🎉", "❤️", "🎂", "💍", "✈️", "🌹", "🥂", "🎁", "💑", "🌟", "🏖️", "🎶", "🍫", "🌙", "💖"]

    init(viewModel: SpecialDaysViewModel, editing: SpecialDay? = nil) {
        self.viewModel = viewModel
        self.editing = editing
        _title = State(initialValue: editing?.title ?? "")
        _emoji = State(initialValue: editing?.emoji ?? "🎉")
        _date = State(initialValue: editing?.date ?? Date())
        _repeatsYearly = State(initialValue: editing?.repeatsYearly ?? true)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("örn. Tanıştığımız gün", text: $title)
                }

                Section("Emoji") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(emojis, id: \.self) { item in
                                Text(item)
                                    .font(.system(size: 26))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(emoji == item
                                                      ? AppColors.primary.opacity(0.18)
                                                      : Color.clear)
                                    )
                                    .overlay(
                                        Circle().stroke(emoji == item ? AppColors.primary : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture { emoji = item }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Tarih") {
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }

                Section {
                    Toggle("Her yıl tekrarla", isOn: $repeatsYearly)
                }
            }
            .navigationTitle(editing == nil ? "Özel Gün Ekle" : "Özel Günü Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let editing {
                            viewModel.update(editing, title: title, emoji: emoji, date: date, repeatsYearly: repeatsYearly)
                        } else {
                            viewModel.add(title: title, emoji: emoji, date: date, repeatsYearly: repeatsYearly)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
