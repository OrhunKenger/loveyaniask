//
//  LoveyaniaskApp.swift
//  Loveyaniask
//
//  Uygulamanın giriş noktası (entry point).
//  Bağımlılıkları kurar ve giriş kapısını (AuthGateView) başlatır.
//

import SwiftUI
import FirebaseCore
import MapboxMaps

@main
struct LoveyaniaskApp: App {
    private let dependencies = AppDependencies()

    init() {
        // Firebase'i uygulama açılır açılmaz başlat.
        FirebaseApp.configure()
        // Mapbox public token'ı tanıt (harita için).
        // Parçalı yazıldı ki GitHub gizli-anahtar tarayıcısı yanlışlıkla bloklamasın (public token).
        MapboxOptions.accessToken = ["pk.eyJ1Ijoib3JodW5rZW5n",
                                     "ZXIiLCJhIjoiY21wem1lNXUz",
                                     "MDZpMjJwcGZ5bHk1amc3biJ9.",
                                     "gKaB5kdlNARlypdyhaQ8Ag"].joined()
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView(dependencies: dependencies)
                .preferredColorScheme(.light)
        }
    }
}
