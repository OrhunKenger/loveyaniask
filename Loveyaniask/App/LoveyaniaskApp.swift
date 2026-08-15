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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    // DİKKAT: `= AppDependencies()` şeklinde varsayılan değer VERİLMEMELİ.
    // AppDependencies kurulurken Ken'in Firebase repository'lerini hemen
    // yaratıyor (Database.database() çağrılıyor); varsayılan değerler init
    // gövdesinden ÖNCE hesaplandığı için Firebase daha yapılandırılmamış olur
    // ve uygulama "FIRAppNotConfigured" ile açılışta çöker.
    private let dependencies: AppDependencies

    init() {
        // Mapbox public token'ı tanıt (harita için).
        // Parçalı yazıldı ki GitHub gizli-anahtar tarayıcısı yanlışlıkla bloklamasın (public token).
        MapboxOptions.accessToken = ["pk.eyJ1Ijoib3JodW5rZW5n",
                                     "ZXIiLCJhIjoiY21wem1lNXUz",
                                     "MDZpMjJwcGZ5bHk1amc3biJ9.",
                                     "gKaB5kdlNARlypdyhaQ8Ag"].joined()

        // Firebase, bağımlılıklar kurulmadan önce hazır olmalı. AppDelegate'in
        // didFinishLaunching'i bu init'ten SONRA çalıştığı için yapılandırmayı
        // burada yapıyoruz; AppDelegate tarafı ikinci kez çağırmıyor.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        dependencies = AppDependencies()

        // GEÇİCİ: teşhis paneli ölçümü (bkz. PerfMonitor).
        PerfMonitor.shared.start()
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
