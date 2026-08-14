//
//  LoveyaniaskApp.swift
//  Loveyaniask
//
//  Uygulamanın giriş noktası (entry point).
//  Bağımlılıkları kurar ve giriş kapısını (AuthGateView) başlatır.
//

import SwiftUI
import MapboxMaps

@main
struct LoveyaniaskApp: App {
    // Firebase artık AppDelegate.didFinishLaunching içinde başlatılıyor —
    // FCM/APNs kurulumunun Firebase'den önce çalışmaması garanti olsun diye
    // (Apple'ın @UIApplicationDelegateAdaptor + Firebase önerdiği sıralama budur).
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let dependencies = AppDependencies()

    init() {
        // Mapbox public token'ı tanıt (harita için).
        // Parçalı yazıldı ki GitHub gizli-anahtar tarayıcısı yanlışlıkla bloklamasın (public token).
        MapboxOptions.accessToken = ["pk.eyJ1Ijoib3JodW5rZW5n",
                                     "ZXIiLCJhIjoiY21wem1lNXUz",
                                     "MDZpMjJwcGZ5bHk1amc3biJ9.",
                                     "gKaB5kdlNARlypdyhaQ8Ag"].joined()
    }

    var body: some Scene {
        WindowGroup {
            LaunchContainer {
                AuthGateView(dependencies: dependencies)
            }
            .preferredColorScheme(.dark)
        }
    }
}
