//
//  MomentRepository.swift
//  Loveyaniask
//

import Foundation

protocol MomentRepository {
    /// Akıştaki tüm anları gerçek zamanlı dinler (yeniden eskiye sıralı).
    func observe(_ onChange: @escaping ([Moment]) -> Void)
    func upload(mediaType: MomentMediaType, fileURL: URL, completion: @escaping (Bool) -> Void)
    func delete(_ moment: Moment)
    /// date nil ise "tekrar göster" iptal edilir.
    func setResurface(_ moment: Moment, date: Date?)
    /// Medyayı (gerekirse indirip) yerel dosya olarak döner.
    func localFileURL(for moment: Moment, completion: @escaping (URL?) -> Void)
}
