//
//  TimeTogether.swift
//  Loveyaniask
//
//  Beraber geçen sürenin parçalanmış hâli (gün / saat / dakika / saniye).
//  Saf değer nesnesi — canlı sayaç bunu kullanır.
//

import Foundation

struct TimeTogether {
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int

    static let zero = TimeTogether(days: 0, hours: 0, minutes: 0, seconds: 0)
}
