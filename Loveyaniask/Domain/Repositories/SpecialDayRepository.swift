//
//  SpecialDayRepository.swift
//  Loveyaniask
//
//  Özel günlerin kaynağı için Domain sözleşmesi.
//

import Foundation

protocol SpecialDayRepository {
    func all() -> [SpecialDay]
}
