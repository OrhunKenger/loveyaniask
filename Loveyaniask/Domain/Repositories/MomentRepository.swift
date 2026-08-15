//
//  MomentRepository.swift
//  Loveyaniask
//

import Foundation

protocol MomentRepository {
    /// Akıştaki tüm anları gerçek zamanlı dinler (yeniden eskiye sıralı).
    func observe(_ onChange: @escaping ([Moment]) -> Void)
    /// Başarılıysa `nil`, değilse gerçek hata döner — çağıran taraf kullanıcıya
    /// "internetini kontrol et" gibi tahmin yürüten bir mesaj göstermesin diye.
    func upload(mediaType: MomentMediaType, fileURL: URL, completion: @escaping (Error?) -> Void)
    func delete(_ moment: Moment)
    /// date nil ise "tekrar göster" iptal edilir.
    func setResurface(_ moment: Moment, date: Date?)
    /// Medyayı (gerekirse indirip) yerel dosya olarak döner.
    func localFileURL(for moment: Moment, completion: @escaping (URL?) -> Void)
}
