//
//  PeriodSettingsSheet.swift
//  Loveyaniask
//
//  Sevgilinin regl bilgilerini ayarladığı ekran (alttan açılan sheet).
//

import SwiftUI

struct PeriodSettingsSheet: View {
    let viewModel: PeriodViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var lastPeriodStart: Date
    @State private var cycleLength: Int
    @State private var periodLength: Int

    init(viewModel: PeriodViewModel) {
        self.viewModel = viewModel
        _lastPeriodStart = State(initialValue: viewModel.settings.lastPeriodStart)
        _cycleLength = State(initialValue: viewModel.settings.cycleLength)
        _periodLength = State(initialValue: viewModel.settings.periodLength)
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
                            periodLength: periodLength
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
