//
//  JarViewModel.swift
//  Loveyaniask
//
//  Aylık zaman kapsülü kavanozu mantığı (Firebase, gerçek zamanlı).
//  Ay boyunca not atılır; ay dolunca ikisi de onaylayınca açılır;
//  açıldıktan sonra okunur ve yeni döngü başlatılır.
//

import Foundation
import Observation

@Observable
final class JarViewModel {
    private(set) var notes: [JarNote] = []
    private(set) var capsule: JarCapsule?

    var showingAdd = false
    var showingReveal = false

    private let currentUser: UserProfile
    private let repository: JarRepository

    init(currentUser: UserProfile, repository: JarRepository) {
        self.currentUser = currentUser
        self.repository = repository
        repository.observeNotes { [weak self] notes in
            self?.notes = notes
        }
        repository.observeCapsule { [weak self] capsule in
            self?.handleCapsule(capsule)
        }
    }

    private func handleCapsule(_ capsule: JarCapsule) {
        self.capsule = capsule
        // Ay dolduysa ve ikisi de onayladıysa kavanozu otomatik aç.
        if capsule.openedAt == nil,
           capsule.state(asOf: Date()) == .ready,
           capsule.bothApproved {
            repository.markOpened(at: Date())
        }
    }

    // MARK: - Türetilen durum

    var count: Int { notes.count }

    var state: JarState { capsule?.state(asOf: Date()) ?? .collecting }

    var isReady: Bool { state == .ready }
    var isOpened: Bool { state == .opened }
    var isCollecting: Bool { state == .collecting }

    /// Açılana kadar kalan gün (toplama aşamasında).
    var daysLeft: Int { capsule?.daysUntilOpenable(asOf: Date()) ?? 0 }

    var myApproved: Bool { capsule?.approved(by: currentUser.rawValue) ?? false }
    var partnerApproved: Bool { capsule?.approved(by: currentUser.partner.rawValue) ?? false }

    var partnerName: String { currentUser.partner.firstName }

    /// Partnerin sevgi takma adı (örn. "Şevvalim" / "Orhim").
    var partnerPetName: String { currentUser.partner.petName }

    /// Not eklenebilir mi? (Sadece kapsül açıkken eklenemez.)
    var canAddNote: Bool { !isOpened }

    var openableDateText: String {
        guard let capsule else { return "" }
        return Self.dateFormatter.string(from: capsule.openableDate)
    }

    var sortedNotes: [JarNote] {
        notes.sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - Aksiyonlar

    func add(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAddNote else { return }
        repository.addNote(text: trimmed, authorKey: currentUser.rawValue)
    }

    /// Bu kullanıcının açma onayını ver/geri al.
    func toggleApproval() {
        repository.setApproval(!myApproved, for: currentUser.rawValue)
    }

    /// Notları sil ve yeni aylık döngüyü başlat (gerçek açılış tarihinden).
    func startNewCycle() {
        repository.startNewCycle(at: Date())
        showingReveal = false
    }

    // MARK: - Yardımcılar

    func authorName(_ note: JarNote) -> String {
        (UserProfile(rawValue: note.authorKey) ?? .orhun).firstName
    }

    func dateText(_ note: JarNote) -> String {
        Self.dateFormatter.string(from: note.createdAt)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()
}
