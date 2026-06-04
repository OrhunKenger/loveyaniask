//
//  AddPlanSheet.swift
//  Loveyaniask
//
//  Yeni plan ekleme: başlık, tarih + saat, not, hatırlatma.
//

import SwiftUI

struct AddPlanSheet: View {
    let viewModel: PlansViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = Date()
    @State private var note = ""
    @State private var remind = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Plan") {
                    TextField("örn. Hastane randevusu", text: $title)
                }

                Section("Tarih ve saat") {
                    DatePicker("Ne zaman", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }

                Section("Not (isteğe bağlı)") {
                    TextField("örn. kimlik getir", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section {
                    Toggle("Hatırlat (1 gün önce + zamanında)", isOn: $remind)
                }
            }
            .navigationTitle("Plan Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        viewModel.add(title: title, date: date, note: note, remindEnabled: remind)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
