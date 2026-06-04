//
//  AddSpecialDaySheet.swift
//  Loveyaniask
//
//  Yeni özel gün ekleme: başlık, emoji, tarih, yıllık tekrar.
//

import SwiftUI

struct AddSpecialDaySheet: View {
    let viewModel: SpecialDaysViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var emoji = "🎉"
    @State private var date = Date()
    @State private var repeatsYearly = true

    private let emojis = ["🎉", "❤️", "🎂", "💍", "✈️", "🌹", "🥂", "🎁", "💑", "🌟", "🏖️", "🎶", "🍫", "🌙", "💖"]

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
            .navigationTitle("Özel Gün Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        viewModel.add(title: title, emoji: emoji, date: date, repeatsYearly: repeatsYearly)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
