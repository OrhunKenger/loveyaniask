//
//  KenBackdrop.swift
//  Loveyaniask
//
//  Ken'in ARKA çizim yuvası. Ekranın arka planıyla içeriği (kartlar) arasına
//  konuyor: Ken derinlikte geriye gidince burada çiziliyor ve kartlar onun
//  üstünü gerçekten kapatıyor.
//
//  Neden ayrı bir view: KenStage her şeyin ÜSTÜNDE, kökte duruyor. Oradan
//  aşağı alsak ekranların opak arka planı Ken'i tamamen yutardı. Gerçek
//  "kartın arkasına geçme" ancak katmanın ekranın içine girmesiyle olur.
//
//  Koordinatlar: Ken'in konumu kök (tüm ekran) uzayında tutuluyor; bu view
//  ise sekme çubuğunun üstünde, daha küçük bir alanda. Aradaki farkı global
//  çerçeveden hesaplayıp telafi ediyoruz.
//

import SwiftUI

struct KenBackdrop: View {
    let companion: KenCompanion

    private let size: CGFloat = 56

    var body: some View {
        GeometryReader { geo in
            let world = companion.world
            let origin = geo.frame(in: .global).origin
            let height = size * 1.15

            if world.isBehind, world.isOnScreen {
                KenCharacterView(
                    behavior: world.activity.behavior,
                    tone: companion.moodTone,
                    isVisible: true
                )
                .frame(width: size, height: height)
                .scaleEffect(world.depthScale)
                .opacity(1 - world.depthDim)
                .position(
                    x: world.screenX - origin.x,
                    y: world.position.y - height / 2 - origin.y
                )
            }
        }
        .allowsHitTesting(false)
    }
}
