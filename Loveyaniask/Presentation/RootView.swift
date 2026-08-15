//
//  RootView.swift
//  Loveyaniask
//
//  Uygulamanın kök kabuğu: kaydırarak geçilen sayfalar (TabView .page)
//  + Instagram tarzı özel alt bar.
//

import SwiftUI

struct RootView: View {
    /// DİKKAT: ViewModel'ler burada YARATILMAZ. Bu struct üstündeki view her
    /// çizildiğinde yeniden kurulur; eskiden init içinde 11 ViewModel + 17
    /// Firebase dinleyicisi baştan bağlanıyor ve uygulama 1-2 fps'e düşüyordu.
    /// Hazır grafiği alıyoruz (bkz. AppViewModels).
    private let vm: AppViewModels
    @State private var selectedTab: AppTab = .home

    private let canEditPeriod: Bool
    private let onSignOut: () -> Void
    private let kenCompanion: KenCompanion

    init(dependencies: AppDependencies, currentUser: UserProfile, onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
        self.kenCompanion = dependencies.kenCompanion
        self.vm = dependencies.viewModels(for: currentUser)
        canEditPeriod = (currentUser == .sevval)
        // Siri kısayolu (App Intent) hangi kullanıcı adına ekleyeceğini bilsin diye sakla.
        UserDefaults.standard.set(currentUser.rawValue, forKey: "currentUserKey")
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    LibraryView(viewModel: vm.library)
                        .tag(AppTab.library)

                    AkisView(viewModel: vm.akis)
                        .tag(AppTab.akis)

                    HomeView(viewModel: vm.home, quickNotesViewModel: vm.quickNotes, profileViewModel: vm.profile, specialDaysViewModel: vm.specialDays, moodViewModel: vm.mood, plansViewModel: vm.plans, jarViewModel: vm.jar, kenCompanion: kenCompanion, isActive: selectedTab == .home, onSignOut: onSignOut)
                        .tag(AppTab.home)

                    PeriodView(viewModel: vm.period, canEdit: canEditPeriod)
                        .tag(AppTab.period)

                    PlacesView(viewModel: vm.places, isActive: selectedTab == .places)
                        .tag(AppTab.places)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                CustomTabBar(selectedTab: $selectedTab)
            }
            .background(AppColors.background.ignoresSafeArea())
            .ignoresSafeArea(.keyboard, edges: .bottom)

            KenCompanionView(companion: kenCompanion)
        }
    }
}
