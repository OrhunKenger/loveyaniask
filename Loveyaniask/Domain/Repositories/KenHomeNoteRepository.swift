//
//  KenHomeNoteRepository.swift
//  Loveyaniask
//
//  Ken'in ana sayfaya bıraktığı notu canlı izler.
//  Bkz. Data/Repositories/FirebaseKenHomeNoteRepository.
//

import Foundation

protocol KenHomeNoteRepository {
    /// Henüz üretilmemişse nil verir.
    func observe(_ onChange: @escaping (KenNote?) -> Void)
}
