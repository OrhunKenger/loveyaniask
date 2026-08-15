//
//  PerfHUD.swift
//  Loveyaniask
//
//  GEÇİCİ TEŞHİS PANELİ — akıcılık sorunu çözülünce kaldırılacak.
//
//  Sol üstte küçük bir kutu. Dokununca detay açılıp kapanıyor, uzun basınca
//  ekranın altına iniyor (üstteki içeriği kapatmasın diye).
//  Değerler saniyede bir güncelleniyor.
//

import SwiftUI

struct PerfHUD: View {
    private let monitor = PerfMonitor.shared

    @State private var expanded = true
    @State private var atBottom = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Circle()
                    .fill(fpsColor)
                    .frame(width: 7, height: 7)
                Text("\(monitor.fps) fps")
                    .foregroundStyle(fpsColor)
                Text("· b\(monitor.versionText)")
                    .foregroundStyle(.white.opacity(0.55))
            }

            if expanded {
                row("takılma", "\(monitor.hitches)/sn · en kötü \(monitor.worstFrameMs) ms")
                row("firebase", "\(monitor.firebasePerSecond)/sn · toplam \(monitor.firebaseTotal)")
                ForEach(monitor.firebaseByName.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { name, count in
                    row("  " + name, "\(count)/sn")
                }
                ForEach(monitor.bodyPerSecond.sorted(by: { $0.value > $1.value }), id: \.key) { name, count in
                    row(name, "\(count)/sn")
                }
            }
        }
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(.white)
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(.black.opacity(0.72))
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: atBottom ? .bottomLeading : .topLeading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .onTapGesture { expanded.toggle() }
        .onLongPressGesture { atBottom.toggle() }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.white.opacity(0.55))
            Text(value)
        }
    }

    private var fpsColor: Color {
        switch monitor.fps {
        case 50...: .green
        case 30..<50: .yellow
        default: .red
        }
    }
}
