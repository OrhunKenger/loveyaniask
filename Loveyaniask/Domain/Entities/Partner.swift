//
//  Partner.swift
//  Loveyaniask
//
//  Çiftin iki tarafı. İleride gerçek isimlerle eşleştirilebilir.
//

import Foundation

enum Partner: String, CaseIterable, Codable, Identifiable {
    case me
    case partner

    var id: String { rawValue }

    var title: String {
        switch self {
        case .me: return "Ben"
        case .partner: return "Sevgilim"
        }
    }
}
