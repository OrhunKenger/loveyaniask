//
//  JarRepository.swift
//  Loveyaniask
//
//  Kavanoz veri sınırı (Domain boundary). Gerçek zamanlı dinleme + yazma.
//  Implementasyonu Data katmanında (Firebase) yapılır.
//

import Foundation

protocol JarRepository {
    /// Kapsül durumunu (döngü başı, onaylar, açılış) canlı dinler.
    func observeCapsule(_ onChange: @escaping (JarCapsule) -> Void)
    /// Notları canlı dinler (eskiden yeniye sıralı).
    func observeNotes(_ onChange: @escaping ([JarNote]) -> Void)

    func addNote(text: String, authorKey: String)
    /// Bir kullanıcının açma onayını ayarlar.
    func setApproval(_ approved: Bool, for authorKey: String)
    /// Her iki onay da geldiğinde kavanozu açılmış olarak işaretler.
    func markOpened(at date: Date)
    /// Notları siler ve yeni döngüyü verilen tarihten başlatır.
    func startNewCycle(at date: Date)

    /// Dinleyicileri bırak.
    func stop()
}
