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
    @State private var plansViewModel: PlansViewModel
    @State private var jarViewModel: JarViewModel

    init(viewModel: HomeViewModel, specialDaysViewModel: SpecialDaysViewModel, plansViewModel: PlansViewModel, jarViewModel: JarViewModel) {
        _viewModel = State(initialValue: viewModel)
        _specialDaysViewModel = State(initialValue: specialDaysViewModel)
        _plansViewModel = State(initialValue: plansViewModel)
        _jarViewModel = State(initialValue: jarViewModel)
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    TimeTogetherCard(viewModel: viewModel)

                    PlansSection(viewModel: plansViewModel)

                    SpecialDaysSection(viewModel: specialDaysViewModel)
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
        plansViewModel: dependencies.makePlansViewModel(currentUser: .orhun),
        jarViewModel: dependencies.makeJarViewModel(currentUser: .orhun)
    )
}
