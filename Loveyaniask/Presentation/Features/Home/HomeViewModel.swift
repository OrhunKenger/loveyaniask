//
//  HomeViewModel.swift
//  Loveyaniask
//
//  Home ekranının sunum mantığı. Use case'i çağırır, sonucu
//  View'ın göstereceği biçime dönüştürür. View'da iş mantığı kalmaz.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var daysTogether: Int = 0
    private(set) var startDate: Date = Date()

    private let getDaysTogether: GetDaysTogetherUseCase

    init(getDaysTogether: GetDaysTogetherUseCase) {
        self.getDaysTogether = getDaysTogether
    }

    func onAppear() {
        let output = getDaysTogether.execute()
        daysTogether = output.days
        startDate = output.startDate
    }

    /// Başlangıç tarihinin Türkçe, okunabilir hâli (örn. "10 Mayıs 2026").
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: startDate)
    }
}
