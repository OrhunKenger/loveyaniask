//
//  PerfMonitor.swift
//  Loveyaniask
//
//  GEÇİCİ TEŞHİS ARACI — akıcılık sorunu çözülünce tamamen kaldırılacak.
//
//  Elimizde profiler yok (Windows'tan geliştiriliyor, Instruments çalıştıramıyoruz),
//  bu yüzden uygulamanın kendisi ölçüyor: gerçek kare hızı, takılan kare sayısı,
//  Firebase dinleyicilerinin ne sıklıkta tetiklendiği ve ağır ekranların
//  body'sinin saniyede kaç kez yeniden çalıştığı.
//
//  Sayaçlar @ObservationIgnored — yani saymak view'ları geçersiz kılmıyor.
//  Ekrandaki değerler saniyede BİR kez yayınlanıyor, böylece panelin kendisi
//  ölçtüğü şeyi bozmuyor.
//

import Foundation
import Observation
import QuartzCore

@Observable
final class PerfMonitor {
    static let shared = PerfMonitor()

    /// Saniyede bir yayınlanan, ekranda gösterilen değerler.
    private(set) var fps = 0
    /// 33 ms'yi (yani ~2 kare) aşan kare sayısı — takılma hissinin ölçüsü.
    private(set) var hitches = 0
    /// Son saniyedeki en uzun kare, milisaniye.
    private(set) var worstFrameMs = 0
    private(set) var firebasePerSecond = 0
    private(set) var bodyPerSecond: [String: Int] = [:]
    /// Uygulama açıldığından beri toplam Firebase geri çağrısı.
    private(set) var firebaseTotal = 0

    @ObservationIgnored private var frameCount = 0
    @ObservationIgnored private var hitchCount = 0
    @ObservationIgnored private var worstFrame: CFTimeInterval = 0
    @ObservationIgnored private var lastFrameAt: CFTimeInterval = 0
    @ObservationIgnored private var firebaseCount = 0
    @ObservationIgnored private var bodyCounts: [String: Int] = [:]
    @ObservationIgnored private var windowStart: CFTimeInterval = 0
    @ObservationIgnored private var link: CADisplayLink?
    @ObservationIgnored private var proxy: Proxy?

    var versionText: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    private init() {}

    func start() {
        guard link == nil else { return }
        let proxy = Proxy { [weak self] link in self?.onFrame(link) }
        self.proxy = proxy
        let link = CADisplayLink(target: proxy, selector: #selector(Proxy.tick(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
        windowStart = CACurrentMediaTime()
    }

    /// Firebase dinleyicisi tetiklendi.
    func countFirebase() {
        firebaseCount += 1
        firebaseTotal += 1
    }

    /// Bir view'ın body'si çalıştı.
    func countBody(_ name: String) {
        bodyCounts[name, default: 0] += 1
    }

    private func onFrame(_ link: CADisplayLink) {
        let now = link.timestamp
        if lastFrameAt > 0 {
            let delta = now - lastFrameAt
            if delta > 0.033 { hitchCount += 1 }
            if delta > worstFrame { worstFrame = delta }
        }
        lastFrameAt = now
        frameCount += 1

        guard now - windowStart >= 1 else { return }
        publish()
        windowStart = now
    }

    private func publish() {
        fps = frameCount
        hitches = hitchCount
        worstFrameMs = Int((worstFrame * 1000).rounded())
        firebasePerSecond = firebaseCount
        bodyPerSecond = bodyCounts

        frameCount = 0
        hitchCount = 0
        worstFrame = 0
        firebaseCount = 0
        bodyCounts.removeAll(keepingCapacity: true)
    }

    /// CADisplayLink hedefi NSObject olmak zorunda; sınıfı @Observable
    /// tutabilmek için araya bu ince katman giriyor.
    private final class Proxy: NSObject {
        private let handler: (CADisplayLink) -> Void
        init(_ handler: @escaping (CADisplayLink) -> Void) { self.handler = handler }
        @objc func tick(_ link: CADisplayLink) { handler(link) }
    }
}
