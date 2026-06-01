//
//  HomeViewModel.swift
//  Loveyaniask
//
//  Home ekranının sunum mantığı. Use case'leri çağırır, sonucu
//  View'ın göstereceği biçime dönüştürür. View'da iş mantığı kalmaz.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var startDate: Date = Date()

    private let getDaysTogether: GetDaysTogetherUseCase
    private let getTimeTogether: GetTimeTogetherUseCase

    init(
        getDaysTogether: GetDaysTogetherUseCase,
        getTimeTogether: GetTimeTogetherUseCase
    ) {
        self.getDaysTogether = getDaysTogether
        self.getTimeTogether = getTimeTogether
    }

    func onAppear() {
        startDate = getDaysTogether.execute().startDate
    }

    /// Canlı sayaç için: verilen ana kadar geçen süreyi döndürür.
    func timeTogether(at date: Date) -> TimeTogether {
        getTimeTogether.execute(asOf: date)
    }

    /// Başlangıç tarihinin Türkçe, okunabilir hâli (örn. "10 Mayıs 2026").
    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: startDate)
    }
}
