//
//  LoveyaniaskApp.swift
//  Loveyaniask
//
//  Uygulamanın giriş noktası (entry point).
//  Bağımlılıkları kurar ve giriş kapısını (AuthGateView) başlatır.
//

import SwiftUI
import FirebaseCore

@main
struct LoveyaniaskApp: App {
    private let dependencies = AppDependencies()

    init() {
        // Firebase'i uygulama açılır açılmaz başlat.
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView(dependencies: dependencies)
        }
    }
}
