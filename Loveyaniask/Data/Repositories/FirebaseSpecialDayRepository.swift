//
//  FirebaseSpecialDayRepository.swift
//  Loveyaniask
//
//  Özel günler: 3 sabit gün (kod) + kullanıcının eklediği günler (Firebase RTDB).
//  specialDays/{uuid} -> { title, emoji, date, repeatsYearly }
//

import Foundation
import FirebaseDatabase

final class FirebaseSpecialDayRepository: SpecialDayRepository {
    private let ref = Database.database().reference().child("specialDays")
    private var custom: [SpecialDay] = []
    private var onChange: (([SpecialDay]) -> Void)?
    private var handle: DatabaseHandle?

    /// Uygulamayla gelen, silinemeyen sabit günler.
    private let builtIn: [SpecialDay] = {
        func make(_ title: String, _ emoji: String, _ month: Int, _ day: Int) -> SpecialDay {
            var c = DateComponents()
            c.year = 2026; c.month = month; c.day = day
            let date = Calendar.current.date(from: c) ?? Date()
            return SpecialDay(id: UUID(), title: title, date: date, emoji: emoji, repeatsYearly: true, isBuiltIn: true)
        }
        return [
            make("Yıldönümümüz", "❤️", 5, 10),
            make("Şevval'in Doğum Günü", "🎂", 9, 28),
            make("Orhun'un Doğum Günü", "🎂", 4, 19)
        ]
    }()

    init() {
        handle = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            var items: [SpecialDay] = []
            for case let child as DataSnapshot in snapshot.children {
                if let day = Self.decode(child) { items.append(day) }
            }
            self.custom = items
            self.onChange?(self.all())
        }
    }

    func all() -> [SpecialDay] { builtIn + custom }

    func observe(_ onChange: @escaping ([SpecialDay]) -> Void) {
        self.onChange = onChange
        onChange(all())
    }

    func add(_ day: SpecialDay) {
        if !custom.contains(where: { $0.id == day.id }) { custom.append(day) }
        onChange?(all())
        ref.child(day.id.uuidString).setValue(Self.encode(day))
    }

    func delete(id: UUID) {
        custom.removeAll { $0.id == id }
        onChange?(all())
        ref.child(id.uuidString).removeValue()
    }

    private static func encode(_ d: SpecialDay) -> [String: Any] {
        [
            "title": d.title,
            "emoji": d.emoji,
            "date": d.date.timeIntervalSince1970,
            "repeatsYearly": d.repeatsYearly
        ]
    }

    private static func decode(_ snap: DataSnapshot) -> SpecialDay? {
        guard let d = snap.value as? [String: Any],
              let id = UUID(uuidString: snap.key),
              let title = d["title"] as? String,
              let emoji = d["emoji"] as? String,
              let ts = d["date"] as? TimeInterval else { return nil }
        let repeats = (d["repeatsYearly"] as? Bool) ?? true
        return SpecialDay(
            id: id, title: title, date: Date(timeIntervalSince1970: ts),
            emoji: emoji, repeatsYearly: repeats, isBuiltIn: false
        )
    }
}
