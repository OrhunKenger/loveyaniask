//
//  PeriodSettingsSheet.swift
//  Loveyaniask
//
//  Şevval'in regl ayarlarını düzenlediği ekran: döngü, hatırlatma, kayıt geçmişi.
//

import SwiftUI

struct PeriodSettingsSheet: View {
    let viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var lastPeriodStart: Date
    @State private var cycleLength: Int
    @State private var periodLength: Int
    @State private var reminderEnabled: Bool

    init(viewModel: PeriodViewModel) {
        self.viewModel = viewModel
        _lastPeriodStart = State(initialValue: viewModel.settings.lastPeriodStart)
        _cycleLength = State(initialValue: viewModel.settings.cycleLength)
        _periodLength = State(initialValue: viewModel.settings.periodLength)
        _reminderEnabled = State(initialValue: viewModel.settings.reminderEnabled)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Son regl başlangıcı") {
                    DatePicker(
                        "Tarih",
                        selection: $lastPeriodStart,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "tr_TR"))
                }

                Section("Döngü bilgileri") {
                    Stepper("Döngü uzunluğu: \(cycleLength) gün", value: $cycleLength, in: 21...40)
                    Stepper("Regl süresi: \(periodLength) gün", value: $periodLength, in: 2...10)
                }

                Section("Hatırlatma") {
                    Toggle("Regl yaklaşınca hatırlat", isOn: $reminderEnabled)
                    if reminderEnabled {
                        Text("10, 5 ve 1 gün önce hatırlatılırsın")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                if !viewModel.logs.isEmpty {
                    Section("Kayıtlı regl başlangıçları") {
                        ForEach(viewModel.logs) { log in
                            Text(viewModel.logDateText(log))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteLog(viewModel.logs[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Regl Ayarları")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        viewModel.save(
                            lastPeriodStart: lastPeriodStart,
                            cycleLength: cycleLength,
                            periodLength: periodLength,
                            reminderEnabled: reminderEnabled
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
