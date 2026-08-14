//
//  KenRoamingLinesRepository.swift
//  Loveyaniask
//
//  Ken'in bulut routine'inin ürettiği, dolaşırken söyleyebileceği taze
//  cümleleri canlı olarak izler. Bkz. Data/Repositories/FirebaseKenRoamingLinesRepository.
//

import Foundation

protocol KenRoamingLinesRepository {
    func observe(_ onChange: @escaping ([String]) -> Void)
}
