//
//  FirebaseKenHomeNoteRepository.swift
//  Loveyaniask
//
//  ken/homeNote -> ya düz bir metin, ya da { text, createdAt } nesnesi.
//  Bulut routine'i bu düğümü her çalıştığında baştan yazar. İki biçimi de
//  okuyoruz: routine bugüne kadar düz metin yazmış olabilir, tarih yoksa
//  notu taze kabul edip gösteriyoruz.
//

import Foundation
import FirebaseDatabase

final class FirebaseKenHomeNoteRepository: KenHomeNoteRepository {
    private let ref = Database.database().reference().child("ken").child("homeNote")
    private var handle: DatabaseHandle?

    func observe(_ onChange: @escaping (KenNote?) -> Void) {
        handle = ref.observe(.value) { snapshot in
            PerfMonitor.shared.countFirebase()
            if let text = snapshot.value as? String, !text.isEmpty {
                onChange(KenNote(text: text, generatedAt: Date()))
                return
            }
            guard
                let d = snapshot.value as? [String: Any],
                let text = d["text"] as? String,
                !text.isEmpty
            else {
                onChange(nil)
                return
            }
            let millis = d["createdAt"] as? Double
            onChange(KenNote(
                text: text,
                generatedAt: millis.map { Date(timeIntervalSince1970: $0 / 1000) } ?? Date()
            ))
        }
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }
}
