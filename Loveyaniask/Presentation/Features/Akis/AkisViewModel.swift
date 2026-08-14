//
//  AkisViewModel.swift
//  Loveyaniask
//
//  Akış ekranının sunum mantığı: anları dinler, günlere gruplar,
//  yükleme/silme/tekrar-göster aksiyonlarını yürütür.
//

import Foundation
import Observation

struct MomentDaySection: Identifiable {
    let id: String   // dayKey
    let date: Date
    let moments: [Moment]
}

@Observable
final class AkisViewModel {
    private(set) var moments: [Moment] = []
    var selectedMoment: Moment?
    var isUploading = false
    var uploadError: String?

    private let observeUseCase: ObserveMomentsUseCase
    private let uploadUseCase: UploadMomentUseCase
    private let deleteUseCase: DeleteMomentUseCase
    private let setResurfaceUseCase: SetMomentResurfaceUseCase
    private let loadMediaUseCase: LoadMomentMediaUseCase
    private let onThisDayScheduler: OnThisDayReminderScheduler
    private let pushSender: PushNotificationSender
    private let kenCompanion: KenCompanion
    private let currentUser: UserProfile

    init(
        observeUseCase: ObserveMomentsUseCase,
        uploadUseCase: UploadMomentUseCase,
        deleteUseCase: DeleteMomentUseCase,
        setResurfaceUseCase: SetMomentResurfaceUseCase,
        loadMediaUseCase: LoadMomentMediaUseCase,
        onThisDayScheduler: OnThisDayReminderScheduler,
        pushSender: PushNotificationSender,
        kenCompanion: KenCompanion,
        currentUser: UserProfile
    ) {
        self.observeUseCase = observeUseCase
        self.uploadUseCase = uploadUseCase
        self.deleteUseCase = deleteUseCase
        self.setResurfaceUseCase = setResurfaceUseCase
        self.loadMediaUseCase = loadMediaUseCase
        self.onThisDayScheduler = onThisDayScheduler
        self.pushSender = pushSender
        self.kenCompanion = kenCompanion
        self.currentUser = currentUser
        onThisDayScheduler.requestAuthorization()
        observeUseCase.execute { [weak self] moments in
            self?.moments = moments
            self?.onThisDayScheduler.checkAndSchedule(moments: moments)
        }
    }

    /// Yeniden eskiye sıralı gün grupları (akış görünümü için).
    var daySections: [MomentDaySection] {
        let grouped = Dictionary(grouping: moments, by: \.dayKey)
        return grouped
            .map { key, items in
                MomentDaySection(id: key, date: items.first?.createdAt ?? Date(), moments: items)
            }
            .sorted { $0.date > $1.date }
    }

    func canDelete(_ moment: Moment) -> Bool {
        moment.author == currentUser
    }

    func authorLabel(_ moment: Moment) -> String {
        moment.author == currentUser ? "Sen" : moment.author.petName
    }

    func upload(mediaType: MomentMediaType, fileURL: URL) {
        isUploading = true
        uploadError = nil
        uploadUseCase.execute(mediaType: mediaType, fileURL: fileURL) { [weak self] success in
            guard let self else { return }
            self.isUploading = false
            if success {
                self.pushSender.send(
                    to: self.currentUser.partner,
                    title: "\(self.currentUser.firstName) Akış'ta bir an paylaştı",
                    body: "Hemen bak 👀",
                    dedupeKey: "moment.\(self.currentUser.rawValue)"
                )
                self.kenCompanion.trigger(.bounce)
            } else {
                self.uploadError = "An paylaşılamadı. İnternet bağlantını kontrol edip tekrar dener misin?"
            }
        }
    }

    func delete(_ moment: Moment) {
        deleteUseCase.execute(moment)
        if selectedMoment?.id == moment.id { selectedMoment = nil }
    }

    func setResurface(_ moment: Moment, date: Date?) {
        setResurfaceUseCase.execute(moment, date: date)
        if let i = moments.firstIndex(where: { $0.id == moment.id }) {
            moments[i].resurfaceAt = date
        }
        if selectedMoment?.id == moment.id {
            selectedMoment?.resurfaceAt = date
        }
    }

    func loadMedia(for moment: Moment, completion: @escaping (URL?) -> Void) {
        loadMediaUseCase.execute(moment, completion: completion)
    }
}
