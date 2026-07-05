//
//  CustomTabBar.swift
//  Loveyaniask
//
//  Yüzen cam kapsül alt bar. Seçili sekmenin arkasında gül→mor "pill"
//  matchedGeometryEffect ile yumuşakça kayar. İkonlar seçilince beyaz + büyür.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var pillNS

    private var switchAnimation: Animation { .spring(response: 0.35, dampingFraction: 0.75) }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let selected = selectedTab == tab
                Button {
                    withAnimation(switchAnimation) { selectedTab = tab }
                } label: {
                    ZStack {
                        if selected {
                            Capsule()
                                .fill(AppColors.accentGradient)
                                .frame(width: 54, height: 40)
                                .matchedGeometryEffect(id: "pill", in: pillNS)
                                .shadow(color: AppColors.primary.opacity(0.5), radius: 10, y: 3)
                        }
                        Image(systemName: selected ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(selected ? .white : AppColors.textSecondary)
                            .scaleEffect(selected ? 1.06 : 1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppColors.surface)
                .overlay(
                    Capsule().fill(
                        LinearGradient(colors: [Color.white.opacity(0.06), .clear],
                                       startPoint: .top, endPoint: .bottom)
                    )
                )
                .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
                .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xs)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    let tabs = AppTab.allCases
                    guard let index = tabs.firstIndex(of: selectedTab) else { return }
                    if value.translation.width < -30, index < tabs.count - 1 {
                        withAnimation(switchAnimation) { selectedTab = tabs[index + 1] }
                    } else if value.translation.width > 30, index > 0 {
                        withAnimation(switchAnimation) { selectedTab = tabs[index - 1] }
                    }
                }
        )
    }
}
