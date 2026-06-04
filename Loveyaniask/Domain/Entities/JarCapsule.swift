//
//  JarCapsule.swift
//  Loveyaniask
//
//  Aylık "zaman kapsülü" kavanozu durumu.
//  Bir ay boyunca not toplanır; ay dolunca ikisi de onaylayınca açılır;
//  açıldıktan sonra yeni döngü gerçek açılış tarihinden itibaren başlar.
//

import Foundation

/// Kavanozun içinde bulunduğu aşama.
enum JarState: Equatable {
    case collecting   // ay henüz dolmadı, not toplanıyor
    case ready        // ay doldu, açılmak için iki onay bekliyor
    case opened       // açıldı, notlar okunabilir
}

struct JarCapsule: Equatable {
    /// Bu döngünün başladığı an.
    var cycleStart: Date
    /// UserProfile.rawValue -> açmayı onayladı mı?
    var approvals: [String: Bool]
    /// Açıldığı an (henüz açılmadıysa nil).
    var openedAt: Date?

    /// Kavanozun açılabilir hale geleceği tarih (döngü başı + 1 ay).
    var openableDate: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: cycleStart) ?? cycleStart
    }

    func state(asOf now: Date) -> JarState {
        if openedAt != nil { return .opened }
        return now >= openableDate ? .ready : .collecting
    }

    func approved(by key: String) -> Bool {
        approvals[key] == true
    }

    var bothApproved: Bool {
        approved(by: UserProfile.orhun.rawValue) && approved(by: UserProfile.sevval.rawValue)
    }

    /// Açılmaya kaç tam gün kaldığı (en az 0).
    func daysUntilOpenable(asOf now: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: now, to: openableDate).day ?? 0
        return max(0, days)
    }
}
