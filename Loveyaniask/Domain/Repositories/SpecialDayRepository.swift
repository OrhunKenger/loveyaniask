//
//  SpecialDayRepository.swift
//  Loveyaniask
//
//  Özel günlerin kaynağı için Domain sözleşmesi.
//

import Foundation

protocol SpecialDayRepository {
    func all() -> [SpecialDay]
    /// Özel günleri gerçek zamanlı dinler (sabit + kullanıcı eklediği).
    func observe(_ onChange: @escaping ([SpecialDay]) -> Void)
    func add(_ day: SpecialDay)
    func delete(id: UUID)
}
