//
//  KenMoodToneRepository.swift
//  Loveyaniask
//
//  Ken'in gövde rengini canlı besleyen "ruh hali tonu": en son (en fazla 7
//  gün geriye giderek) girilmiş ruh hallerinden 0 (sıcak/olumlu) ile 1
//  (soğuk/zor) arasında tek bir değer. Bkz. Data/Repositories/FirebaseKenMoodToneRepository.
//

import Foundation

protocol KenMoodToneRepository {
    /// Veri yoksa (son 7 günde hiç kayıt yoksa) nil döner.
    func observe(_ onChange: @escaping (Double?) -> Void)
}
