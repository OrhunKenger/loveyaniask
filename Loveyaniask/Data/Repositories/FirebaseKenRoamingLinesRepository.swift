//
//  FirebaseKenRoamingLinesRepository.swift
//  Loveyaniask
//
//  ken/roamingLines -> ["<kısa cümle>", "<kısa cümle>", ...]
//  Bulut routine'i her çalıştığında bu diziyi baştan yazar (append değil).
//  Client bunu canlı dinleyip Ken'in dokunma havuzuna karıştırır.
//

import Foundation
import FirebaseDatabase

final class FirebaseKenRoamingLinesRepository: KenRoamingLinesRepository {
    private let ref = Database.database().reference().child("ken").child("roamingLines")
    private var handle: DatabaseHandle?

    func observe(_ onChange: @escaping ([String]) -> Void) {
        handle = ref.observe(.value) { snapshot in
            PerfMonitor.shared.countFirebase()
            let lines: [String]
            if let array = snapshot.value as? [String] {
                lines = array
            } else if let dict = snapshot.value as? [String: String] {
                lines = Array(dict.values)
            } else {
                lines = []
            }
            onChange(lines)
        }
    }

    deinit {
        if let handle { ref.removeObserver(withHandle: handle) }
    }
}
