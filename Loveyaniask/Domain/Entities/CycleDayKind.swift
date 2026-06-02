//
//  CycleDayKind.swift
//  Loveyaniask
//
//  Bir günün döngüdeki türü — takvimde renklendirmek için.
//

import Foundation

enum CycleDayKind {
    case period      // regl günü
    case fertile     // doğurgan pencere
    case ovulation   // yumurtlama günü
    case none        // normal gün
}
