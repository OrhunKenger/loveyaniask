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
    @State private var quickNotesViewModel: QuickNotesViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel
    @State private var plansViewModel: PlansViewModel
    @State private var jarViewModel: JarViewModel
    @State private var moodViewModel: MoodViewModel
    @State private var periodViewModel: PeriodViewModel
    @State private var placesViewModel: PlacesViewModel
    @State private var libraryViewModel: LibraryViewModel
    @State private var selectedTab: AppTab = .home

    private let canEditPeriod: Bool
    private let onSignOut: () -> Void

    init(dependencies: AppDependencies, currentUser: UserProfile, onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
        _homeViewModel = State(initialValue: dependencies.makeHomeViewModel())
        _quickNotesViewModel = State(initialValue: dependencies.makeQuickNotesViewModel(currentUser: currentUser))
        _specialDaysViewModel = State(initialValue: dependencies.makeSpecialDaysViewModel())
        _plansViewModel = State(initialValue: dependencies.makePlansViewModel(currentUser: currentUser))
        _jarViewModel = State(initialValue: dependencies.makeJarViewModel(currentUser: currentUser))
        _moodViewModel = State(initialValue: dependencies.makeMoodViewModel(currentUser: currentUser))
        _periodViewModel = State(initialValue: dependencies.makePeriodViewModel())
        _placesViewModel = State(initialValue: dependencies.makePlacesViewModel(currentUser: currentUser))
        _libraryViewModel = State(initialValue: dependencies.makeLibraryViewModel(currentUser: currentUser))
        canEditPeriod = (currentUser == .sevval)
        // Siri kısayolu (App Intent) hangi kullanıcı adına ekleyeceğini bilsin diye sakla.
        UserDefaults.standard.set(currentUser.rawValue, forKey: "currentUserKey")
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                LibraryView(viewModel: libraryViewModel)
                    .tag(AppTab.library)

                WishlistView(viewModel: placesViewModel)
                    .tag(AppTab.wishlist)

                HomeView(viewModel: homeViewModel, quickNotesViewModel: quickNotesViewModel, specialDaysViewModel: specialDaysViewModel, moodViewModel: moodViewModel, plansViewModel: plansViewModel, jarViewModel: jarViewModel, isActive: selectedTab == .home, onSignOut: onSignOut)
                    .tag(AppTab.home)

                PeriodView(viewModel: periodViewModel, canEdit: canEditPeriod)
                    .tag(AppTab.period)

                PlacesView(viewModel: placesViewModel, isActive: selectedTab == .places)
                    .tag(AppTab.places)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(AppColors.background)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
