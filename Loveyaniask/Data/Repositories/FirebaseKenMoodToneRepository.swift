//
//  FirebaseKenMoodToneRepository.swift
//  Loveyaniask
//
//  mood/{yyyy-MM-dd}/{orhun|sevval} ağacını dinler, en son veri bulunan günün
//  (son 7 gün içinde) ortalama "sıcaklık" konumunu hesaplar. Mood.displayOrder
//  içindeki konum, MoodHomeSection.valenceColor ile birebir aynı 0(sıcak)...
//  1(soğuk) skalasını kullanır — Ken'in rengi uygulamanın geri kalanıyla tutarlı olsun diye.
//

import Foundation
import FirebaseDatabase

final class FirebaseKenMoodToneRepository: KenMoodToneRepository {
    private let ref = Database.database().reference().child("mood")
    private var handle: DatabaseHandle?

    func observe(_ onChange: @escaping (Double?) -> Void) {
        handle = ref.observe(.value) { snapshot in
            PerfMonitor.shared.countFirebase()
            guard let root = snapshot.value as? [String: Any] else {
                onChange(nil)
                return
            }
            onChange(Self.mostRecentTone(in: root))
        }
    }

    private static func mostRecentTone(in root: [String: Any]) -> Double? {
        let order = Mood.displayOrder
        guard order.count > 1 else { return nil }
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            let key = formatter.string(from: date)
            guard let day = root[key] as? [String: Any] else { continue }

            var positions: [Double] = []
            for userKey in ["orhun", "sevval"] {
                guard let entry = day[userKey] as? [String: Any],
                      let rawValue = entry["mood"] as? String,
                      let mood = Mood(rawValue: rawValue),
                      let index = order.firstIndex(of: mood) else { continue }
                positions.append(Double(index) / Double(order.count - 1))
            }

            if !positions.isEmpty {
                return positions.reduce(0, +) / Double(positions.count)
            }
        }
        return nil
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }
}
