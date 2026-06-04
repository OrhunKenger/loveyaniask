//
//  AddPlanSheet.swift
//  Loveyaniask
//
//  Yeni plan ekleme: başlık, tarih + saat, not, hatırlatma.
//

import SwiftUI

struct AddPlanSheet: View {
    let viewModel: PlansViewModel
    let editing: Plan?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var date: Date
    @State private var note: String
    @State private var remind: Bool

    init(viewModel: PlansViewModel, editing: Plan? = nil) {
        self.viewModel = viewModel
        self.editing = editing
        _title = State(initialValue: editing?.title ?? "")
        _date = State(initialValue: editing?.date ?? Date())
        _note = State(initialValue: editing?.note ?? "")
        _remind = State(initialValue: editing?.remindEnabled ?? true)
    }

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
            .navigationTitle(editing == nil ? "Plan Ekle" : "Planı Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let editing {
                            viewModel.update(editing, title: title, date: date, note: note, remindEnabled: remind)
                        } else {
                            viewModel.add(title: title, date: date, note: note, remindEnabled: remind)
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
