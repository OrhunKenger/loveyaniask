//
//  PlanRepository.swift
//  Loveyaniask
//
//  Yaklaşan planların kaynağı için Domain sözleşmesi (gerçek zamanlı).
//

import Foundation

protocol PlanRepository {
    func observe(_ onChange: @escaping ([Plan]) -> Void)
    func add(_ plan: Plan)
    func delete(id: UUID)
}
