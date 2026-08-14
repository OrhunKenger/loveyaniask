//
//  AppDelegate.swift
//  Loveyaniask
//
//  Push bildirimleri (FCM) için köprü: APNs token'ı Firebase'e iletir, FCM
//  token'ı alıp giriş yapmış kullanıcının altına kaydeder (users/{key}/fcmToken)
//  — böylece partnerin cihazına push göndermek isteyen sunucu tarafı,
//  "kime gönderecek" bilgisini oradan bulur.
//
//  NOT: Xcode projesine "FirebaseMessaging" SPM ürününün eklenmesi gerekiyor.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseDatabase

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Normalde LoveyaniaskApp.init() içinde yapılandırılmış oluyor (bağımlılıklar
        // Firebase'e daha erken dokunduğu için); burası sadece emniyet kemeri.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, let userKey = UserDefaults.standard.string(forKey: "currentUserKey") else { return }
        Database.database().reference().child("users").child(userKey).child("fcmToken").setValue(fcmToken)
    }

    /// Uygulama açıkken push gelirse de banner + ses göster.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
