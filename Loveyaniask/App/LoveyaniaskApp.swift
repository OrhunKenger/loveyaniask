//
//  LoveyaniaskApp.swift
//  Loveyaniask
//
//  Uygulamanın giriş noktası (entry point).
//  Bağımlılıkları kurar ve kök ekranı başlatır.
//

import SwiftUI

@main
struct LoveyaniaskApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView(
                homeViewModel: dependencies.makeHomeViewModel(),
                moodViewModel: dependencies.makeMoodViewModel(),
                periodViewModel: dependencies.makePeriodViewModel()
            )
        }
    }
}
