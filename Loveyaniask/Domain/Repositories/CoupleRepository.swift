//
//  CoupleRepository.swift
//  Loveyaniask
//
//  Domain katmanının veriye erişim SÖZLEŞMESİ (protokol).
//  Gerçek implementasyon Data katmanında yapılır.
//  Bağımlılık tersine çevirme (Dependency Inversion) buradan gelir.
//

import Foundation

protocol CoupleRepository {
    func fetchCouple() -> Couple
}
