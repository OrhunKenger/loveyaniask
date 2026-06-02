//
//  LoveyaniaskApp.swift
//  Loveyaniask
//
//  Uygulamanın giriş noktası (entry point).
//  Bağımlılıkları kurar ve giriş kapısını (AuthGateView) başlatır.
//

import SwiftUI

@main
struct LoveyaniaskApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AuthGateView(dependencies: dependencies)
        }
    }
}
