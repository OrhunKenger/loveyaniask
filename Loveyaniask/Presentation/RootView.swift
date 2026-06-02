//
//  RootView.swift
//  Loveyaniask
//
//  Uygulamanın kök kabuğu: kaydırarak geçilen sayfalar (TabView .page)
//  + Instagram tarzı özel alt bar.
//

import SwiftUI

struct RootView: View {
    let homeViewModel: HomeViewModel
    let periodViewModel: PeriodViewModel

    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: homeViewModel)
                    .tag(AppTab.home)

                PeriodView(viewModel: periodViewModel)
                    .tag(AppTab.period)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(AppColors.background)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
