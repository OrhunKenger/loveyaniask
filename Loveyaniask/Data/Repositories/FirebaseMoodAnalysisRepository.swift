//
//  FirebaseMoodAnalysisRepository.swift
//  Loveyaniask
//
//  moodAnalysis/latest -> { text, generatedAt } yolunu dinler.
//  Bu kayıt bulutta zamanlanmış çalışan bir Claude routine'i tarafından yazılır
//  (mood/ altında değişiklik olduğunda moodMeta/lastChangedAt güncellenir,
//  routine bunu görüp analiz üretir).
//

import Foundation
import FirebaseDatabase

final class FirebaseMoodAnalysisRepository: MoodAnalysisRepository {
    private let ref = Database.database().reference().child("moodAnalysis").child("latest")
    private var handle: DatabaseHandle?

    func observe(_ onChange: @escaping (MoodAnalysis?) -> Void) {
        handle = ref.observe(.value) { snapshot in
            PerfMonitor.shared.countFirebase()
            guard
                let d = snapshot.value as? [String: Any],
                let text = d["text"] as? String
            else {
                onChange(nil)
                return
            }
            let millis = d["generatedAt"] as? Double ?? 0
            onChange(MoodAnalysis(text: text, generatedAt: Date(timeIntervalSince1970: millis / 1000)))
        }
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }
}
