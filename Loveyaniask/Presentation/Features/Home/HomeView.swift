//
//  HomeView.swift
//  Loveyaniask
//
//  Ana ekran: canlı sayaç, özel günler, "birbirimiz hakkında" kavanozu.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var specialDaysViewModel: SpecialDaysViewModel
    @State private var moodViewModel: MoodViewModel
    @State private var plansViewModel: PlansViewModel
    @State private var jarViewModel: JarViewModel
    /// Home sekmesi seçili mi? Canlı sayaç sadece görünürken çalışsın diye.
    var isActive: Bool = true

    init(viewModel: HomeViewModel, specialDaysViewModel: SpecialDaysViewModel, moodViewModel: MoodViewModel, plansViewModel: PlansViewModel, jarViewModel: JarViewModel, isActive: Bool = true) {
        _viewModel = State(initialValue: viewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
        _moodViewModel = State(initialValue: moodViewModel)
        _plansViewModel = State(initialValue: plansViewModel)
        _jarViewModel = State(initialValue: jarViewModel)
        self.isActive = isActive
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TimeTogetherCard(viewModel: viewModel, isActive: isActive)

                    SpecialDaysSection(viewModel: specialDaysViewModel)

                    MoodHomeSection(viewModel: moodViewModel)

                    PlansSection(viewModel: plansViewModel)
                }
                .padding(AppSpacing.md)
            }

            // Yüzen, sürüklenebilir kavanoz (her şeyin üstünde).
            MemoryJarSection(viewModel: jarViewModel)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    return HomeView(
        viewModel: dependencies.makeHomeViewModel(),
        specialDaysViewModel: dependencies.makeSpecialDaysViewModel(),
        moodViewModel: dependencies.makeMoodViewModel(currentUser: .orhun),
        plansViewModel: dependencies.makePlansViewModel(currentUser: .orhun),
        jarViewModel: dependencies.makeJarViewModel(currentUser: .orhun)
    )
}
