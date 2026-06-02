//
//  RootView.swift
//  Loveyaniask
//
//  Uygulamanın kök kabuğu: kaydırarak geçilen sayfalar (TabView .page)
//  + Instagram tarzı özel alt bar. ViewModel'leri bir kez kurar.
//

import SwiftUI

struct RootView: View {
    @State private var homeViewModel: HomeViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel
    @State private var moodViewModel: MoodViewModel
    @State private var periodViewModel: PeriodViewModel
    @State private var selectedTab: AppTab = .home

    init(dependencies: AppDependencies) {
        _homeViewModel = State(initialValue: dependencies.makeHomeViewModel())
        _specialDaysViewModel = State(initialValue: dependencies.makeSpecialDaysViewModel())
        _moodViewModel = State(initialValue: dependencies.makeMoodViewModel())
        _periodViewModel = State(initialValue: dependencies.makePeriodViewModel())
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                MoodView(viewModel: moodViewModel)
                    .tag(AppTab.mood)

                HomeView(viewModel: homeViewModel, specialDaysViewModel: specialDaysViewModel)
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
