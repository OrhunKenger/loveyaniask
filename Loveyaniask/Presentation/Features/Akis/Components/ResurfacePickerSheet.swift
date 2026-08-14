//
//  ResurfacePickerSheet.swift
//  Loveyaniask
//
//  "Bunu tekrar göster" tepkisi için tarih seçimi — en fazla 3 ay ileri.
//

import SwiftUI

struct ResurfacePickerSheet: View {
    let moment: Moment
    var onConfirm: (Date) -> Void
    var onCancel: () -> Void

    private let calendar = Calendar.current
    @State private var selectedDate: Date

    init(moment: Moment, onConfirm: @escaping (Date) -> Void, onCancel: @escaping () -> Void) {
        self.moment = moment
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        let start = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        _selectedDate = State(initialValue: moment.resurfaceAt ?? start)
    }

    private var minDate: Date {
        calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? Date()
    }

    private var maxDate: Date {
        calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                Text("Bu anı ikinize de sürpriz bir bildirimle tekrar göstereceğiz. En fazla 3 ay sonrasını seçebilirsin.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                DatePicker(
                    "Tarih",
                    selection: $selectedDate,
                    in: minDate...maxDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "tr_TR"))
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, AppSpacing.lg)
            .navigationTitle("Tekrar Göster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ayarla") { onConfirm(selectedDate) }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
