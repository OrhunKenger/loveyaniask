//
//  AddPlanIntent.swift
//  Loveyaniask
//
//  Siri / Kısayollar ile yeni plan ekleme (App Intents).
//  "Hey Siri, Loveyaniask plan ekle" → başlık ve tarih sorar, Firebase'e yazar.
//

import AppIntents
import Foundation
import FirebaseCore
import FirebaseDatabase

struct AddPlanIntent: AppIntent {
    static var title: LocalizedStringResource = "Plan Ekle"
    static var description = IntentDescription("Loveyaniask'a yeni bir yaklaşan plan ekler.")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Plan", requestValueDialog: "Hangi plan?")
    var planTitle: String

    @Parameter(title: "Tarih ve saat", requestValueDialog: "Ne zaman?")
    var date: Date

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$planTitle) planını \(\.$date) tarihine ekle")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Siri arka planda çalışabilir; Firebase kurulu değilse kur.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let authorKey = UserDefaults.standard.string(forKey: "currentUserKey") ?? "orhun"
        let id = UUID().uuidString
        let ref = Database.database().reference().child("plans").child(id)
        let data: [String: Any] = [
            "title": planTitle,
            "date": date.timeIntervalSince1970,
            "note": "",
            "remindEnabled": true,
            "authorKey": authorKey
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.setValue(data) { error, _ in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        return .result(dialog: "\(planTitle) planı eklendi 💕")
    }
}

struct LoveyaniaskShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddPlanIntent(),
            phrases: [
                "\(.applicationName) plan ekle",
                "\(.applicationName)'a plan ekle",
                "\(.applicationName) hatırlat"
            ],
            shortTitle: "Plan Ekle",
            systemImageName: "calendar.badge.plus"
        )
    }
}
